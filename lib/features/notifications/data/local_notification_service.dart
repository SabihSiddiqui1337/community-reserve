import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../shared/time/app_time.dart';

/// Called with a deep-link route when a local notification is tapped.
typedef NotificationRouteHandler = void Function(String route);

/// Thin wrapper around flutter_local_notifications. Used to (a) deep-link on
/// tap and (b) fire the DEMO "slot opened" notification a few seconds out so
/// the waitlist flow can be verified on-device without a real push backend.
class LocalNotifications {
  LocalNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static NotificationRouteHandler? _onRoute;
  static bool _inited = false;

  static Future<void> init(NotificationRouteHandler onRoute) async {
    _onRoute = onRoute;
    if (_inited) return;
    _inited = true;

    const settings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (resp) => _dispatch(resp.payload),
    );

    // App launched cold by tapping a local notification.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _dispatch(launch!.notificationResponse?.payload,
          delay: const Duration(milliseconds: 600));
    }
  }

  static void _dispatch(String? payload, {Duration delay = Duration.zero}) {
    if (payload == null || payload.isEmpty) return;
    if (delay == Duration.zero) {
      _onRoute?.call(payload);
    } else {
      Future.delayed(delay, () => _onRoute?.call(payload));
    }
  }

  /// Schedule a "check in now" reminder 10 minutes before [startLocal]. Tapping
  /// it deep-links to the reservation detail. No-op if start is <10 min away.
  static Future<void> scheduleCheckInReminder({
    required String reservationId,
    required String amenityName,
    required DateTime startLocal,
    required String timezoneName,
  }) async {
    final fireAt = AppTime.inZone(startLocal.toUtc(), timezoneName)
        .subtract(const Duration(minutes: 10));
    if (!fireAt.isAfter(AppTime.now(timezoneName))) return;
    await _plugin.zonedSchedule(
      id: 'checkin_$reservationId'.hashCode & 0x7fffffff,
      title: 'Check in now',
      body: 'Your $amenityName reservation is ready — tap to check in.',
      scheduledDate: fireAt,
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'checkin',
          'Check-in reminders',
          channelDescription: 'Reminds you to check in for a reservation',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '/reservation/$reservationId',
    );
  }

  /// DEMO: fire a "slot opened" notification [seconds] from now, so you can tap
  /// the bell, close the app, and confirm delivery + deep-link. Scheduled at
  /// the OS level so it fires even when the app is backgrounded or closed.
  /// Remove together with the demo hook in SlotScreen when no longer needed.
  static Future<void> scheduleDemoSlotOpen({
    required String title,
    required String body,
    required String route,
    required String timezoneName,
    int seconds = 5,
  }) async {
    final when = AppTime.now(timezoneName).add(Duration(seconds: seconds));
    await _plugin.zonedSchedule(
      id: when.millisecondsSinceEpoch ~/ 1000 & 0x7fffffff,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'waitlist',
          'Slot openings',
          channelDescription: 'Alerts when a booked slot opens up',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: route,
    );
  }
}

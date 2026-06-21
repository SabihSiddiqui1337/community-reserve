import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import 'local_notification_service.dart';

/// Best-effort FCM token registration + notification-tap deep-linking for the
/// signed-in user. Watching this provider (e.g. on the shell) kicks it off
/// once. Web push needs a VAPID key + service worker, so it's skipped there —
/// the in-app inbox is the reliable channel. Mobile registers the token to
/// `users/{uid}.fcmTokens` so Cloud Functions can target the device.
final fcmRegistrationProvider = Provider<void>((ref) {
  if (kIsWeb) return;
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return;
  // Fire-and-forget; never throws into the widget tree.
  _register(ref, uid);
});

Future<void> _register(Ref ref, String uid) async {
  try {
    // Local notifications (DEMO + tap deep-linking) — route taps to the router.
    await LocalNotifications.init((route) => ref.read(routerProvider).go(route));

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null) {
      await ref.read(userRepositoryProvider).addFcmToken(uid, token);
    }

    // App opened from a notification while backgrounded.
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _handleTap(ref, m));
    // App launched cold by tapping a notification (terminated state).
    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleTap(ref, initial);
  } catch (e) {
    debugPrint('FCM registration skipped: $e');
  }
}

/// Navigate to the route carried in a notification's data payload, if any.
void _handleTap(Ref ref, RemoteMessage message) {
  final route = message.data['route'];
  if (route is String && route.isNotEmpty) {
    ref.read(routerProvider).go(route);
  }
}

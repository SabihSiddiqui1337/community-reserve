import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';

/// Best-effort FCM token registration for the signed-in user. Watching this
/// provider (e.g. on Home) kicks off registration once. Web push needs a VAPID
/// key + service worker, so it's skipped there for now — the in-app inbox is
/// the reliable channel. Mobile registers the token to `users/{uid}.fcmTokens`
/// so Cloud Functions can target the device.
final fcmRegistrationProvider = Provider<void>((ref) {
  if (kIsWeb) return;
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return;
  // Fire-and-forget; never throws into the widget tree.
  _register(ref, uid);
});

Future<void> _register(Ref ref, String uid) async {
  try {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null) {
      await ref.read(userRepositoryProvider).addFcmToken(uid, token);
    }
  } catch (e) {
    debugPrint('FCM registration skipped: $e');
  }
}

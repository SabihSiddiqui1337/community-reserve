import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/app_notification.dart';

class NotificationRepository {
  NotificationRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String cid) =>
      _db.collection('communities').doc(cid).collection('notifications');

  Stream<List<AppNotification>> watchForUser(String cid, String uid) =>
      _col(cid).where('userId', isEqualTo: uid).snapshots().map((q) =>
          q.docs
              .map((d) => AppNotification.fromJson({...d.data(), 'id': d.id}))
              .toList()
            ..sort((a, b) => (b.createdAt ?? DateTime(0))
                .compareTo(a.createdAt ?? DateTime(0))));

  Future<void> markRead(String cid, String id) =>
      _col(cid).doc(id).set({'read': true}, SetOptions(merge: true));
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(firestoreProvider)),
);

final myNotificationsProvider =
    StreamProvider<List<AppNotification>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  final uid = ref.watch(currentUidProvider);
  if (cid == null || uid == null) return Stream.value(const []);
  return ref.watch(notificationRepositoryProvider).watchForUser(cid, uid);
});

/// Count of unread notifications (for a home badge).
final unreadCountProvider = Provider<int>((ref) {
  final list = ref.watch(myNotificationsProvider).value ?? const [];
  return list.where((n) => !n.read).length;
});

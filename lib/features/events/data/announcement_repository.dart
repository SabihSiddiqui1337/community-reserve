import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/announcement.dart';

class AnnouncementRepository {
  AnnouncementRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String cid) =>
      _db.collection('communities').doc(cid).collection('announcements');

  Stream<List<Announcement>> watchAll(String cid) =>
      _col(cid).orderBy('createdAt', descending: true).snapshots().map((q) => q
          .docs
          .map((d) => Announcement.fromJson({...d.data(), 'id': d.id}))
          .toList());

  Future<void> post(String cid, Announcement a) =>
      _col(cid).add(a.toJson()..remove('id')..['createdAt'] = Timestamp.now());

  Future<void> delete(String cid, String id) => _col(cid).doc(id).delete();
}

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => AnnouncementRepository(ref.watch(firestoreProvider)),
);

final announcementsProvider = StreamProvider<List<Announcement>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return Stream.value(const []);
  return ref.watch(announcementRepositoryProvider).watchAll(cid);
});

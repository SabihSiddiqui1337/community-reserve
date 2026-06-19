import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/waitlist_entry.dart';

class WaitlistRepository {
  WaitlistRepository(this._db, this._functions);
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> _col(String cid) =>
      _db.collection('communities').doc(cid).collection('waitlist');

  Stream<List<WaitlistEntry>> watchForUser(String cid, String uid) =>
      _col(cid).where('userId', isEqualTo: uid).snapshots().map((q) => q.docs
          .map((d) => WaitlistEntry.fromJson({...d.data(), 'id': d.id}))
          .toList());

  Future<void> join({
    required String communityId,
    required String amenityId,
    required DateTime desiredStart,
    required DateTime desiredEnd,
  }) async {
    final callable = _functions.httpsCallable('joinWaitlist');
    await callable.call<Map<String, dynamic>>({
      'communityId': communityId,
      'amenityId': amenityId,
      'desiredStart': desiredStart.toUtc().toIso8601String(),
      'desiredEnd': desiredEnd.toUtc().toIso8601String(),
    });
  }
}

final waitlistRepositoryProvider = Provider<WaitlistRepository>(
  (ref) => WaitlistRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  ),
);

final myWaitlistProvider = StreamProvider<List<WaitlistEntry>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  final uid = ref.watch(currentUidProvider);
  if (cid == null || uid == null) return Stream.value(const []);
  return ref.watch(waitlistRepositoryProvider).watchForUser(cid, uid);
});

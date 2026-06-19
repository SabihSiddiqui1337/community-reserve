import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../domain/community.dart';

/// Reads tenant documents from `communities/{id}`. The root of multi-tenant
/// data access; everything else hangs off the resolved [Community].
class CommunityRepository {
  CommunityRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('communities');

  /// Live stream of a single community. Emits [Community.demo] as a fallback
  /// if the document does not exist yet (e.g. seed hasn't run), so the UI is
  /// always branded.
  Stream<Community> watch(String communityId) {
    return _col.doc(communityId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return Community.demo();
      return Community.fromJson({...data, 'id': snap.id});
    });
  }

  Future<Community> fetch(String communityId) async {
    final snap = await _col.doc(communityId).get();
    final data = snap.data();
    if (data == null) return Community.demo();
    return Community.fromJson({...data, 'id': snap.id});
  }

  /// Admin: merge-update community fields (branding, settings, name, flags).
  Future<void> update(String communityId, Map<String, dynamic> data) =>
      _col.doc(communityId).set(data, SetOptions(merge: true));
}

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepository(ref.watch(firestoreProvider)),
);

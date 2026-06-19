import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../domain/community_summary.dart';

/// Public discovery for the join flow (`communityDirectory/`). Readable before
/// the user is a member, so it intentionally exposes only summary fields.
class CommunityDirectoryRepository {
  CommunityDirectoryRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('communityDirectory');

  CommunitySummary _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) =>
      CommunitySummary.fromJson({...?d.data(), 'id': d.id});

  /// Resolve a join code (case-insensitive) to a single community.
  Future<CommunitySummary?> lookupByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    final q =
        await _col.where('joinCode', isEqualTo: normalized).limit(1).get();
    if (q.docs.isEmpty) return null;
    return _fromDoc(q.docs.first);
  }

  /// Prefix search by name. U+F8FF is a very-high private-use code point, so
  /// the range [term, term + U+F8FF] matches every name starting with `term`.
  Future<List<CommunitySummary>> searchByName(String term) async {
    final t = term.trim();
    if (t.isEmpty) return [];
    final end = t + String.fromCharCode(0xf8ff);
    final q = await _col
        .orderBy('name')
        .startAt([t])
        .endAt([end])
        .limit(8)
        .get();
    return q.docs.map(_fromDoc).toList();
  }
}

final communityDirectoryRepositoryProvider =
    Provider<CommunityDirectoryRepository>(
  (ref) => CommunityDirectoryRepository(ref.watch(firestoreProvider)),
);

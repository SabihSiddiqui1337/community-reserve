import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/amenity.dart';

class AmenityRepository {
  AmenityRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String cid) =>
      _db.collection('communities').doc(cid).collection('amenities');

  Stream<List<Amenity>> watchAll(String cid) => _col(cid).snapshots().map((q) =>
      q.docs.map((d) => Amenity.fromJson({...d.data(), 'id': d.id})).toList());

  Stream<Amenity?> watch(String cid, String id) =>
      _col(cid).doc(id).snapshots().map((d) {
        final data = d.data();
        return data == null ? null : Amenity.fromJson({...data, 'id': d.id});
      });

  /// Admin: create or update an amenity. A blank id mints a new document.
  Future<void> save(String cid, Amenity amenity) async {
    final id = amenity.id.isEmpty ? _col(cid).doc().id : amenity.id;
    // json_serializable doesn't convert nested objects by default, so the
    // `pricing` field would serialize as a raw Dart object that Firestore
    // rejects ("Unsupported field value: a custom object"). Flatten it.
    final data = amenity.copyWith(id: id).toJson()
      ..remove('id')
      ..['pricing'] = amenity.pricing.toJson();
    await _col(cid).doc(id).set(data);
  }

  Future<void> delete(String cid, String id) => _col(cid).doc(id).delete();
}

final amenityRepositoryProvider = Provider<AmenityRepository>(
  (ref) => AmenityRepository(ref.watch(firestoreProvider)),
);

/// All amenities in the active community.
final amenitiesProvider = StreamProvider<List<Amenity>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return Stream.value(const []);
  return ref.watch(amenityRepositoryProvider).watchAll(cid);
});

/// A single amenity by id.
final amenityProvider = StreamProvider.family<Amenity?, String>((ref, id) {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return Stream.value(null);
  return ref.watch(amenityRepositoryProvider).watch(cid, id);
});

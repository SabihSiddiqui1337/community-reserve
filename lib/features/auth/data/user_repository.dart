import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../payments/domain/payment_method.dart';
import '../domain/app_user.dart';
import 'auth_repository.dart';

/// Reads/writes the global `users/{uid}` profile.
class UserRepository {
  UserRepository(this._db, this._storage);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  /// Create the profile on first sign-up if it doesn't exist yet.
  Future<void> ensureProfile(AppUser user) async {
    final ref = _doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set(user.toJson()..remove('uid'));
    }
  }

  Stream<AppUser?> watch(String uid) => _doc(uid).snapshots().map((snap) {
        final data = snap.data();
        if (data == null) return null;
        return AppUser.fromJson({...data, 'uid': snap.id});
      });

  Future<void> addFcmToken(String uid, String token) =>
      _doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));

  /// Replace the user's saved cards (demo — last 4 only). Optionally set the
  /// selected card id.
  Future<void> setPaymentMethods(
    String uid,
    List<PaymentMethod> methods, {
    String? selectedId,
  }) =>
      _doc(uid).set({
        'paymentMethods': methods.map((m) => m.toJson()).toList(),
        'selectedCardId': ?selectedId,
      }, SetOptions(merge: true));

  Future<void> selectCard(String uid, String cardId) =>
      _doc(uid).set({'selectedCardId': cardId}, SetOptions(merge: true));

  /// Update editable profile fields. Only non-null values are written.
  Future<void> updateProfile(
    String uid, {
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) =>
      _doc(uid).set({
        'name': ?name,
        'email': ?email,
        'phone': ?phone,
        'photoUrl': ?photoUrl,
      }, SetOptions(merge: true));

  /// Upload a profile photo to `users/{uid}/avatar.jpg`, return its URL.
  Future<String> uploadAvatar(
    String uid,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final ref = _storage.ref().child('users/$uid/avatar.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  ),
);

/// The signed-in user's profile, streamed.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(userRepositoryProvider).watch(uid);
});

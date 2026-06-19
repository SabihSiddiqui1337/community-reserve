import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';

/// Uploads residency-verification documents to
/// `communities/{cid}/residency/{uid}/{file}` and returns a download URL.
class ResidencyRepository {
  ResidencyRepository(this._storage);

  final FirebaseStorage _storage;

  Future<String> uploadDocument({
    required String communityId,
    required String uid,
    required String fileName,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final ref = _storage
        .ref()
        .child('communities/$communityId/residency/$uid/$fileName');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}

final residencyRepositoryProvider = Provider<ResidencyRepository>(
  (ref) => ResidencyRepository(ref.watch(firebaseStorageProvider)),
);

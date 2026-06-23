import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';

/// A resident's request to reserve an event space. Unlike a court booking it
/// isn't an instant paid reservation — it's an inquiry sent to the community
/// organizer/admin, who follows up. Stored at
/// `communities/{cid}/eventRequests/{id}`.
class EventRequestRepository {
  EventRequestRepository(this._db);
  final FirebaseFirestore _db;

  Future<void> submit({
    required String communityId,
    required String amenityId,
    required String userId,
    required DateTime start,
    required DateTime end,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String message,
  }) async {
    await _db
        .collection('communities')
        .doc(communityId)
        .collection('eventRequests')
        .add({
      'amenityId': amenityId,
      'userId': userId,
      'startTime': Timestamp.fromDate(start),
      'endTime': Timestamp.fromDate(end),
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'message': message,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }
}

final eventRequestRepositoryProvider = Provider<EventRequestRepository>(
  (ref) => EventRequestRepository(ref.watch(firestoreProvider)),
);

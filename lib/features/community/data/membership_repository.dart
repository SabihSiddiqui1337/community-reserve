import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../domain/membership.dart';

/// A membership paired with the community it belongs to (resolved from the
/// document path during a collection-group query).
class MembershipRecord {
  const MembershipRecord({required this.communityId, required this.membership});
  final String communityId;
  final Membership membership;
}

/// Reads/writes `communities/{cid}/memberships/{uid}`. Drives the onboarding
/// gate (joined? verified?) and the admin approvals queue.
class MembershipRepository {
  MembershipRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String cid) =>
      _db.collection('communities').doc(cid).collection('memberships');

  Stream<Membership?> watch(String cid, String uid) =>
      _col(cid).doc(uid).snapshots().map((snap) {
        final data = snap.data();
        if (data == null) return null;
        return Membership.fromJson({...data, 'userId': snap.id});
      });

  /// All communities a user belongs to (collection-group by `userId`). MVP
  /// uses the first; multi-community switching can come later.
  Stream<List<MembershipRecord>> watchUserMemberships(String uid) => _db
      .collectionGroup('memberships')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((q) => q.docs
          .map((d) => MembershipRecord(
                communityId: d.reference.parent.parent!.id,
                membership: Membership.fromJson({...d.data(), 'userId': d.id}),
              ))
          .toList());

  /// Resident joins a community — creates a pending membership (keeps `userId`
  /// in the doc so collection-group queries can find it).
  Future<void> join(String cid, String uid, {String unit = ''}) async {
    // A brand-new resident creates their OWN membership (a *create*). We must
    // not pre-check with get() — the rules deny reading a membership doc that
    // doesn't exist yet for a non-member, so the get() would throw and bounce
    // signup back to "find your community". set() on a missing doc is a create,
    // which the rules allow (role=resident, residencyStatus=pending, own uid).
    await _col(cid).doc(uid).set(Membership(userId: uid, unit: unit).toJson());
  }

  /// Attach the uploaded residency doc; (re)sets status to pending. `unit` is
  /// the suite/unit line; `address` is the composed street/city/state/zip line.
  Future<void> submitResidency(String cid, String uid, String docUrl,
      {String unit = '', String address = ''}) {
    return _col(cid).doc(uid).set({
      'userId': uid,
      'verificationDocUrl': docUrl,
      'residencyStatus': ResidencyStatus.pending.name,
      if (unit.isNotEmpty) 'unit': unit,
      if (address.isNotEmpty) 'address': address,
    }, SetOptions(merge: true));
  }

  /// Admin: pending residency submissions for review.
  Stream<List<Membership>> watchPending(String cid) => _col(cid)
      .where('residencyStatus', isEqualTo: ResidencyStatus.pending.name)
      .snapshots()
      .map((q) => q.docs
          .map((d) => Membership.fromJson({...d.data(), 'userId': d.id}))
          .toList());

  Stream<List<Membership>> watchAll(String cid) => _col(cid).snapshots().map(
      (q) => q.docs
          .map((d) => Membership.fromJson({...d.data(), 'userId': d.id}))
          .toList());

  Future<void> approve(String cid, String uid, String reviewerUid) =>
      _col(cid).doc(uid).set({
        'residencyStatus': ResidencyStatus.verified.name,
        'reviewedBy': reviewerUid,
        'reviewedAt': Timestamp.now(),
        'rejectionReason': null,
      }, SetOptions(merge: true));

  Future<void> reject(
          String cid, String uid, String reviewerUid, String reason) =>
      _col(cid).doc(uid).set({
        'residencyStatus': ResidencyStatus.rejected.name,
        'reviewedBy': reviewerUid,
        'reviewedAt': Timestamp.now(),
        'rejectionReason': reason,
      }, SetOptions(merge: true));
}

final membershipRepositoryProvider = Provider<MembershipRepository>(
  (ref) => MembershipRepository(ref.watch(firestoreProvider)),
);

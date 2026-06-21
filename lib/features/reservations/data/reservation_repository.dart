import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/reservation.dart';

class ReservationRepository {
  ReservationRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> _col(String cid) =>
      _db.collection('communities').doc(cid).collection('reservations');

  Reservation _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) =>
      Reservation.fromJson({...?d.data(), 'id': d.id});

  /// A user's reservations, newest first.
  Stream<List<Reservation>> watchForUser(String cid, String uid) => _col(cid)
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((q) => (q.docs.map(_fromDoc).toList()
        ..sort((a, b) => (b.startTime ?? DateTime(0))
            .compareTo(a.startTime ?? DateTime(0)))));

  /// All reservations for an amenity within a day window (availability calc).
  Stream<List<Reservation>> watchForAmenityRange(
          String cid, String amenityId, DateTime dayStart, DateTime dayEnd) =>
      _col(cid)
          .where('amenityId', isEqualTo: amenityId)
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
          .where('startTime', isLessThan: Timestamp.fromDate(dayEnd))
          .snapshots()
          .map((q) => q.docs.map(_fromDoc).toList());

  Reservation? _fromMaybe(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    return data == null ? null : Reservation.fromJson({...data, 'id': d.id});
  }

  /// A single reservation, streamed (for the detail screen).
  Stream<Reservation?> watch(String cid, String id) =>
      _col(cid).doc(id).snapshots().map(_fromMaybe);

  /// Admin: all reservations in the community, newest first.
  Stream<List<Reservation>> watchAll(String cid) =>
      _col(cid).snapshots().map((q) => q.docs.map(_fromDoc).toList()
        ..sort((a, b) => (b.startTime ?? DateTime(0))
            .compareTo(a.startTime ?? DateTime(0))));

  /// Admin override cancel (rules allow community admins to set status).
  Future<void> adminCancel(String cid, String id) => _col(cid).doc(id).set(
        {'status': 'cancelled', 'cancelledAt': Timestamp.now()},
        SetOptions(merge: true),
      );

  /// Create a reservation through the Cloud Function (server enforces rules).
  /// Returns the new id plus the one-time PIN and signed QR token.
  Future<({String reservationId, String pin, String qrToken})>
      createReservation({
    required String communityId,
    required String amenityId,
    required DateTime start,
    required DateTime end,
    String? paymentId,
    int? court,
  }) async {
    final callable = _functions.httpsCallable('createReservation');
    final result = await callable.call<Map<String, dynamic>>({
      'communityId': communityId,
      'amenityId': amenityId,
      'startTime': start.toUtc().toIso8601String(),
      'endTime': end.toUtc().toIso8601String(),
      'paymentId': ?paymentId,
      'court': ?court,
    });
    return (
      reservationId: result.data['reservationId'] as String,
      pin: result.data['pin'] as String,
      qrToken: result.data['qrToken'] as String,
    );
  }

  /// Validate a PIN/QR (also performs first-time check-in). Server-enforced.
  Future<Map<String, dynamic>> validateAccess({
    required String communityId,
    String? reservationId,
    String? pin,
    String? qrToken,
  }) async {
    final callable = _functions.httpsCallable('validateAccess');
    final result = await callable.call<Map<String, dynamic>>({
      'communityId': communityId,
      'reservationId': ?reservationId,
      'pin': ?pin,
      'qrToken': ?qrToken,
    });
    return result.data;
  }

  Future<Map<String, dynamic>> cancel({
    required String communityId,
    required String reservationId,
  }) async {
    final callable = _functions.httpsCallable('cancelReservation');
    final result = await callable.call<Map<String, dynamic>>({
      'communityId': communityId,
      'reservationId': reservationId,
    });
    return Map<String, dynamic>.from(result.data);
  }
}

final reservationRepositoryProvider = Provider<ReservationRepository>(
  (ref) => ReservationRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  ),
);

/// The signed-in user's reservations in the active community.
final myReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  final uid = ref.watch(currentUidProvider);
  if (cid == null || uid == null) return Stream.value(const []);
  return ref.watch(reservationRepositoryProvider).watchForUser(cid, uid);
});

/// A single reservation by id (detail screen).
final reservationProvider =
    StreamProvider.family<Reservation?, String>((ref, id) {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return Stream.value(null);
  return ref.watch(reservationRepositoryProvider).watch(cid, id);
});

/// Admin: every reservation in the active community.
final allReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return Stream.value(const []);
  return ref.watch(reservationRepositoryProvider).watchAll(cid);
});

/// Cache of one-time PINs returned at booking, keyed by reservation id. The raw
/// PIN is never persisted server-side (only its hash), so the booking device
/// keeps its own copy — persisted to local storage so it survives app restarts
/// and can be revealed on check-in.
class PinCache extends Notifier<Map<String, String>> {
  static const _prefix = 'pin_';

  @override
  Map<String, String> build() {
    _loadFromDisk();
    return {};
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = <String, String>{
      for (final k in prefs.getKeys())
        if (k.startsWith(_prefix))
          k.substring(_prefix.length): prefs.getString(k) ?? '',
    };
    if (entries.isNotEmpty) state = {...entries, ...state};
  }

  void put(String reservationId, String pin) {
    state = {...state, reservationId: pin};
    SharedPreferences.getInstance()
        .then((p) => p.setString('$_prefix$reservationId', pin));
  }
}

final pinCacheProvider =
    NotifierProvider<PinCache, Map<String, String>>(PinCache.new);

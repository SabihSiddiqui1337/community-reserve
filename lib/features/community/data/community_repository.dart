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

  CollectionReference<Map<String, dynamic>> get _dir =>
      _db.collection('communityDirectory');

  /// Owner: create a brand-new community — the tenant doc plus its public
  /// directory entry (so it appears on the Sign-up screen) — in one batch.
  /// Returns the new community id.
  Future<String> createCommunity({
    required String name,
    required String address,
    String? residentPortalUrl,
    String city = '',
    String state = '',
    String zip = '',
    String joinCode = '',
    String timezone = 'America/Chicago',
  }) async {
    final id = _col.doc().id;
    final batch = _db.batch();
    batch.set(_col.doc(id), {
      'name': name,
      'address': _composeAddress(address, city, state, zip),
      'timezone': timezone,
      'residentPortalUrl': _normalizePortalUrl(residentPortalUrl),
      'branding': {
        'logoUrl': null,
        'primaryColor': '#FFFFFF',
        'accentColor': '#C7CBD1',
        'backgroundUrl': null,
        'theme': 'dark',
      },
      'settings': {
        'maxBookingHoursPerWeek': 3,
        'advanceBookingDays': 7,
        'maxActiveReservationsPerUser': 2,
        'checkInGraceMinutes': 15,
        'noShowThreshold': 3,
        'noShowBanDays': 30,
        'cancellationCutoffMinutes': 60,
        'cancellationAllowance': 2,
        'taxEnabled': true,
      },
      'featureFlags': {
        'paymentsEnabled': true,
        'gymEnabled': false,
        'waitlistEnabled': true,
      },
    });
    batch.set(_dir.doc(id), {
      'name': name,
      'street': address.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'zip': zip.trim(),
      'logoUrl': null,
      'joinCode': joinCode.trim().toUpperCase(),
      'primaryColor': '#FFFFFF',
    });
    await batch.commit();
    return id;
  }

  /// Stores an absolute URL — adds `https://` when the user omits the scheme
  /// (e.g. "youtube.com") — or null when blank, so the HOA portal opens the
  /// real site instead of a path inside this app.
  static String? _normalizePortalUrl(String? url) {
    final u = url?.trim() ?? '';
    if (u.isEmpty) return null;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return 'https://$u';
  }

  /// Builds a single-line address from its parts, skipping any that are blank:
  /// "100 Main St, Austin, TX 78701".
  static String _composeAddress(
      String street, String city, String state, String zip) {
    final stateZip = [state.trim(), zip.trim()]
        .where((p) => p.isNotEmpty)
        .join(' ');
    return [street.trim(), city.trim(), stateZip]
        .where((p) => p.isNotEmpty)
        .join(', ');
  }

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

  /// Owner: edit an existing community's core details — including the HOA link
  /// (set it to swap "Coming Soon" for the live portal). Keeps the public
  /// directory entry in sync.
  Future<void> updateCommunity({
    required String id,
    required String name,
    required String address,
    String? residentPortalUrl,
    String city = '',
    String state = '',
    String zip = '',
    String joinCode = '',
  }) async {
    final batch = _db.batch();
    batch.set(
        _col.doc(id),
        {
          'name': name,
          'address': _composeAddress(address, city, state, zip),
          'residentPortalUrl': _normalizePortalUrl(residentPortalUrl),
        },
        SetOptions(merge: true));
    batch.set(
        _dir.doc(id),
        {
          'name': name,
          'street': address.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'zip': zip.trim(),
          'joinCode': joinCode.trim().toUpperCase(),
        },
        SetOptions(merge: true));
    await batch.commit();
  }
}

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepository(ref.watch(firestoreProvider)),
);

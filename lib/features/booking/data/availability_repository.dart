import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/availability.dart';

class AvailabilityRepository {
  AvailabilityRepository(this._functions);
  final FirebaseFunctions _functions;

  Future<List<BusyInterval>> fetch({
    required String communityId,
    required String amenityId,
    required DateTime dayStart,
    required DateTime dayEnd,
  }) async {
    final callable = _functions.httpsCallable('getAvailability');
    final r = await callable.call<Map<String, dynamic>>({
      'communityId': communityId,
      'amenityId': amenityId,
      'dayStartIso': dayStart.toUtc().toIso8601String(),
      'dayEndIso': dayEnd.toUtc().toIso8601String(),
    });
    final raw = (r.data['busy'] as List?) ?? const [];
    return raw
        .map((m) => BusyInterval.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList();
  }
}

final availabilityRepositoryProvider = Provider<AvailabilityRepository>(
  (ref) => AvailabilityRepository(ref.watch(firebaseFunctionsProvider)),
);

/// Busy intervals for an amenity on a given day (server-computed, no private
/// data). autoDispose so it re-fetches when you revisit after booking.
final dayAvailabilityProvider = FutureProvider.autoDispose
    .family<List<BusyInterval>, ({String amenityId, DateTime day})>(
        (ref, args) async {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return const [];
  final dayStart = DateTime(args.day.year, args.day.month, args.day.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  return ref.watch(availabilityRepositoryProvider).fetch(
        communityId: cid,
        amenityId: args.amenityId,
        dayStart: dayStart,
        dayEnd: dayEnd,
      );
});

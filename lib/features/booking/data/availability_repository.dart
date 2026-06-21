import 'dart:async';

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
/// data). Cached for ~90s so re-opening a sport / flipping days is instant
/// instead of paying the callable round-trip each time; booking invalidates the
/// whole family (see checkout) to keep it fresh.
final dayAvailabilityProvider = FutureProvider.autoDispose
    .family<List<BusyInterval>, ({String amenityId, DateTime day})>(
        (ref, args) async {
  // Keep the result alive briefly after the screen is left so navigating back
  // doesn't refetch.
  final link = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 90), link.close);
  ref.onDispose(timer.cancel);

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

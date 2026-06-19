import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/routes.dart';
import '../../../amenities/data/amenity_repository.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../reservations/data/reservation_repository.dart';
import '../../../reservations/domain/reservation.dart';

class AdminReservationsScreen extends ConsumerWidget {
  const AdminReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(allReservationsProvider);
    final amenities = ref.watch(amenitiesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.admin),
        ),
      ),
      body: reservations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No reservations.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = list[i];
              final name = amenities
                      .where((a) => a.id == r.amenityId)
                      .firstOrNull
                      ?.name ??
                  r.amenityId;
              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(r.startTime == null
                      ? r.status.name
                      : '${DateFormat('MMM d · h:mm a').format(r.startTime!)} · ${r.status.name}'),
                  trailing: (r.status == ReservationStatus.booked ||
                          r.status == ReservationStatus.checkedIn)
                      ? IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          tooltip: 'Cancel',
                          onPressed: () => _cancel(context, ref, r.id),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, String id) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    await ref.read(reservationRepositoryProvider).adminCancel(cid, id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reservation cancelled.')));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../reservations/data/reservation_repository.dart';
import '../../../reservations/domain/reservation.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(allReservationsProvider);
    final members = ref.watch(allMembershipsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.admin),
        ),
      ),
      body: reservations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          final total = list.length;
          final noShows =
              list.where((r) => r.status == ReservationStatus.noShow).length;
          final completed = list
              .where((r) => r.status == ReservationStatus.completed)
              .length;
          final active = list
              .where((r) =>
                  r.status == ReservationStatus.booked ||
                  r.status == ReservationStatus.checkedIn)
              .length;
          final memberCount = members.value?.length ?? 0;
          final noShowRate =
              total == 0 ? 0 : ((noShows / total) * 100).round();

          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _Stat(label: 'Total reservations', value: '$total', icon: Icons.event),
              _Stat(label: 'Upcoming / active', value: '$active', icon: Icons.upcoming),
              _Stat(label: 'Completed', value: '$completed', icon: Icons.check_circle_outline),
              _Stat(label: 'No-shows', value: '$noShows', icon: Icons.person_off_outlined),
              _Stat(label: 'No-show rate', value: '$noShowRate%', icon: Icons.percent),
              _Stat(label: 'Members', value: '$memberCount', icon: Icons.groups_outlined),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const Spacer(),
            Text(value,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

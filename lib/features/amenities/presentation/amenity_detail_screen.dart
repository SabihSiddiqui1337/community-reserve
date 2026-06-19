import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/money/money.dart';
import '../data/amenity_repository.dart';
import '../domain/amenity.dart';
import 'amenities_list_screen.dart';

class AmenityDetailScreen extends ConsumerWidget {
  const AmenityDetailScreen({super.key, required this.amenityId});
  final String amenityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amenity = ref.watch(amenityProvider(amenityId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.amenities),
        ),
      ),
      body: amenity.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (a) {
          if (a == null) {
            return const Center(child: Text('Amenity not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(a.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StatusBadge(status: a.status),
              const SizedBox(height: 16),
              Text(a.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              _InfoRow(
                  icon: Icons.schedule,
                  label: 'Hours',
                  value: '${a.openHour}:00 – ${a.closeHour}:00'),
              _InfoRow(
                  icon: Icons.timelapse,
                  label: 'Slot length',
                  value: '${a.slotMinutes} min'),
              _InfoRow(
                  icon: Icons.groups,
                  label: 'Capacity',
                  value: '${a.capacity}'),
              _InfoRow(
                icon: Icons.payments_outlined,
                label: 'Price',
                value: a.pricing.isPaid
                    ? Money.format(a.pricing.amountCents,
                        currency: a.pricing.currency)
                    : 'Free',
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: a.isBookable
                    ? () => context.go(Routes.bookingTo(a.id))
                    : null,
                icon: const Icon(Icons.event_available),
                label: Text(a.isBookable
                    ? 'Book a slot'
                    : a.status == AmenityStatus.comingSoon
                        ? 'Coming soon'
                        : 'Unavailable'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

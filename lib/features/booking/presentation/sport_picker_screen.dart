import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../amenities/domain/amenity.dart';

/// Display order for the sport/space picker (Event Hall first).
int _order(String type) => switch (type) {
      'hall' => 0,
      'pickleballCourt' => 1,
      'basketball' => 2,
      _ => 3,
    };

IconData _iconFor(String type) => switch (type) {
      'hall' => Icons.celebration_outlined,
      'pickleballCourt' => Icons.sports_tennis,
      'basketball' => Icons.sports_basketball,
      'gym' => Icons.fitness_center,
      _ => Icons.location_city,
    };

class SportPickerScreen extends ConsumerWidget {
  const SportPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amenities = ref.watch(amenitiesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: amenities.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) {
            final sorted = [...list]
              ..sort((a, b) => _order(a.type).compareTo(_order(b.type)));
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Book',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Choose what you’d like to reserve',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 20),
                for (var i = 0; i < sorted.length; i++)
                  _SportCard(amenity: sorted[i])
                      .animate()
                      .fadeIn(delay: (i * 70).ms)
                      .slideY(begin: 0.1),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  const _SportCard({required this.amenity});
  final Amenity amenity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookable = amenity.isBookable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: bookable
              ? () => context.go(Routes.bookSlotsTo(amenity.id))
              : null,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_iconFor(amenity.type),
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(amenity.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Icon(bookable ? Icons.chevron_right : Icons.lock_outline,
                    color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

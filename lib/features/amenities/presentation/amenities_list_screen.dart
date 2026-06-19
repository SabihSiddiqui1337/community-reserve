import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../data/amenity_repository.dart';
import '../domain/amenity.dart';

class AmenitiesListScreen extends ConsumerWidget {
  const AmenitiesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amenities = ref.watch(amenitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amenities'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go(Routes.home),
        ),
      ),
      body: amenities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No amenities yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _AmenityCard(amenity: list[i])
                .animate()
                .fadeIn(delay: (i * 60).ms)
                .slideY(begin: 0.1),
          );
        },
      ),
    );
  }
}

class _AmenityCard extends StatelessWidget {
  const _AmenityCard({required this.amenity});
  final Amenity amenity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Routes.amenityDetailTo(amenity.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_iconFor(amenity.type),
                    color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(amenity.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(amenity.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    StatusBadge(status: amenity.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        'pickleballCourt' => Icons.sports_tennis,
        'gym' => Icons.fitness_center,
        'hall' => Icons.celebration,
        _ => Icons.location_city,
      };
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final AmenityStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AmenityStatus.active => ('Live', Colors.green),
      AmenityStatus.comingSoon => ('Coming soon', Colors.orange),
      AmenityStatus.maintenance => ('Maintenance', Colors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

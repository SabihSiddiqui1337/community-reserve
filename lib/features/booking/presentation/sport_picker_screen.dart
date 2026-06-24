import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_theme.dart';
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

/// Photo asset to use as the card thumbnail (falls back to an icon when null).
String? _imageFor(String type) => switch (type) {
      'pickleballCourt' => 'assets/images/pickleball.png',
      'basketball' => 'assets/images/basketball.png',
      _ => null,
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
                if (sorted.isEmpty)
                  const _NoFacilities()
                else
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

/// Shown on the Book tab when the community has no amenities configured yet.
class _NoFacilities extends StatelessWidget {
  const _NoFacilities();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Icon(Icons.sports_tennis_outlined,
              size: 56, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          const Text('Facilities Coming Soon',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            "This community's facilities will appear here once they're added.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// 60×60 rounded thumbnail: a photo asset when available, else a lime-gradient
/// icon tile. When [enabled] is false (coming soon / maintenance) it greys out.
class _SportThumb extends StatelessWidget {
  const _SportThumb({required this.type, this.enabled = true});
  final String type;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = _imageFor(type);
    if (image != null) {
      final img = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(image, height: 60, width: 60, fit: BoxFit.cover),
      );
      return enabled ? img : Opacity(opacity: 0.45, child: img);
    }
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary
              ])
            : null,
        color: enabled ? null : theme.colorScheme.surfaceContainerHighest,
        border: enabled
            ? null
            : Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(_iconFor(type),
          color: enabled ? AppTheme.onLime : theme.colorScheme.onSurfaceVariant,
          size: 28),
    );
  }
}

/// Small grey pill shown on unbookable amenities ("Coming Soon"/"Maintenance").
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          )),
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
    final statusLabel = switch (amenity.status) {
      AmenityStatus.comingSoon => 'Coming Soon',
      AmenityStatus.maintenance => 'Maintenance',
      _ => null,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        // Unbookable amenities sit on a flatter, lighter grey so they read as
        // disabled (not tappable).
        color: bookable
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                _SportThumb(type: amenity.type, enabled: bookable),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(amenity.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            bookable ? null : theme.colorScheme.onSurfaceVariant,
                      )),
                ),
                if (bookable)
                  Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant)
                else if (statusLabel != null)
                  _StatusChip(label: statusLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

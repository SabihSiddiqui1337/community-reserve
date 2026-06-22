import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../amenities/domain/amenity.dart';
import '../../notifications/data/notification_repository.dart';

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
                Row(
                  children: [
                    Text('Book',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const _NotificationsBell(),
                  ],
                ),
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

/// 60×60 rounded thumbnail: a photo asset when available, else a lime-gradient
/// icon tile.
class _SportThumb extends StatelessWidget {
  const _SportThumb({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = _imageFor(type);
    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(image,
            height: 60, width: 60, fit: BoxFit.cover),
      );
    }
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(_iconFor(type), color: AppTheme.onLime, size: 28),
    );
  }
}

/// Bell with an unread badge that opens the in-app notification inbox.
class _NotificationsBell extends ConsumerWidget {
  const _NotificationsBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unread = ref.watch(unreadCountProvider);
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => context.push(Routes.notifications),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        backgroundColor: theme.colorScheme.error,
        child: const Icon(Icons.notifications_none),
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
                _SportThumb(type: amenity.type),
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

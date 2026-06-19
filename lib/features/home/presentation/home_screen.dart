import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/branded_background.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/domain/community.dart';
import '../../notifications/data/fcm_service.dart';
import '../../notifications/data/notification_repository.dart';
import '../../reservations/data/reservation_repository.dart';
import '../../reservations/domain/reservation.dart';

/// Resident home. Shows the active community's branding, upcoming reservations
/// (Phase 2+), a quick-book CTA, and entry points to amenities / admin.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(activeCommunityProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final theme = Theme.of(context);
    ref.watch(fcmRegistrationProvider); // best-effort push registration

    return Scaffold(
      body: BrandedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(community: community),
                const SizedBox(height: 28),
                Text('Upcoming reservations',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                const Expanded(child: _UpcomingReservations()),
                if (isAdmin) ...[
                  OutlinedButton.icon(
                    onPressed: () => context.go(Routes.admin),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Admin dashboard'),
                  ),
                  const SizedBox(height: 8),
                ],
                FilledButton.icon(
                  onPressed: () => context.go(Routes.amenities),
                  icon: const Icon(Icons.add),
                  label: const Text('Book an amenity'),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.community});
  final Community community;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      children: [
        BrandLogo(label: community.name, size: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome to', style: theme.textTheme.bodyMedium),
              Text(
                community.name,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Waitlist',
          onPressed: () => context.go(Routes.waitlist),
          icon: const Icon(Icons.hourglass_bottom),
        ),
        _InboxButton(),
        IconButton(
          tooltip: 'Profile',
          onPressed: () => context.go(Routes.profile),
          icon: const Icon(Icons.person_outline),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1);
  }
}

class _UpcomingReservations extends ConsumerWidget {
  const _UpcomingReservations();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(myReservationsProvider);
    final amenities = ref.watch(amenitiesProvider).value ?? const [];

    return reservations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (list) {
        final upcoming = list.where((r) => r.isUpcoming).toList();
        if (upcoming.isEmpty) return const _EmptyReservations();
        return ListView.separated(
          itemCount: upcoming.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final r = upcoming[i];
            final amenity =
                amenities.where((a) => a.id == r.amenityId).firstOrNull;
            return _ReservationCard(
              title: amenity?.name ?? 'Reservation',
              start: r.startTime,
              active: r.isActiveNow,
              onTap: () => context.go(Routes.reservationTo(r.id)),
            );
          },
        );
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.title,
    required this.start,
    required this.active,
    required this.onTap,
  });
  final String title;
  final DateTime? start;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: active
              ? theme.colorScheme.secondary
              : theme.colorScheme.primaryContainer,
          child: Icon(active ? Icons.lock_open : Icons.event,
              color: active
                  ? theme.colorScheme.onSecondary
                  : theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(start == null
            ? ''
            : DateFormat('EEE, MMM d · h:mm a').format(start!)),
        trailing: active
            ? Chip(
                label: const Text('Active'),
                backgroundColor: theme.colorScheme.secondaryContainer,
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _InboxButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return IconButton(
      tooltip: 'Inbox',
      onPressed: () => context.go(Routes.inbox),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.event_available,
                color: theme.colorScheme.secondary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'No reservations yet. Your booked courts, gym and hall '
                'sessions will appear here.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

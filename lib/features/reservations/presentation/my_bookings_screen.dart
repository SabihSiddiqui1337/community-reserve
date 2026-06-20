import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../amenities/data/amenity_repository.dart';
import '../data/reservation_repository.dart';
import '../domain/reservation.dart';
import 'reservation_detail_dialog.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(myReservationsProvider);
    final amenities = ref.watch(amenitiesProvider).value ?? const [];

    String nameFor(String id) =>
        amenities.where((a) => a.id == id).firstOrNull?.name ?? 'Reservation';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [Tab(text: 'Upcoming'), Tab(text: 'History')],
          ),
        ),
        body: reservations.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) {
            final upcoming = list.where((r) => r.isUpcoming).toList();
            final history = list.where((r) => !r.isUpcoming).toList();
            return TabBarView(
              children: [
                upcoming.isEmpty
                    ? const _EmptyUpcoming()
                    : _BookingsList(items: upcoming, nameFor: nameFor),
                history.isEmpty
                    ? const Center(child: Text('No past bookings.'))
                    : _BookingsList(items: history, nameFor: nameFor),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({required this.items, required this.nameFor});
  final List<Reservation> items;
  final String Function(String) nameFor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final r = items[i];
        final active = r.isActiveNow;
        // Cancelled / no-show / expired bookings aren't tappable.
        final clickable = r.status == ReservationStatus.booked ||
            r.status == ReservationStatus.checkedIn ||
            r.status == ReservationStatus.completed;
        return Card(
          child: ListTile(
            onTap: clickable
                ? () => showReservationDetailDialog(context, r.id)
                : null,
            leading: CircleAvatar(
              backgroundColor: active
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primaryContainer,
              child: Icon(active ? Icons.lock_open : Icons.event,
                  color: active
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onPrimaryContainer),
            ),
            title: Text(nameFor(r.amenityId),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text([
              if (r.startTime != null)
                DateFormat('EEE, MMM d · h:mm a').format(r.startTime!),
              if (r.court != null) 'Court ${r.court}',
            ].join(' · ')),
            trailing: _trailing(theme, r.status, active),
          ),
        );
      },
    );
  }
}

Widget _trailing(ThemeData theme, ReservationStatus status, bool active) {
  if (active) {
    return Chip(
      label: const Text('Active'),
      backgroundColor: theme.colorScheme.secondaryContainer,
      side: BorderSide.none,
    );
  }
  switch (status) {
    case ReservationStatus.booked:
    case ReservationStatus.checkedIn:
    case ReservationStatus.completed:
      return const Icon(Icons.chevron_right);
    case ReservationStatus.cancelled:
    case ReservationStatus.noShow:
    case ReservationStatus.expired:
      final label = switch (status) {
        ReservationStatus.cancelled => 'CANCELLED',
        ReservationStatus.noShow => 'NO-SHOW',
        _ => 'EXPIRED',
      };
      return Text(label,
          style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12));
  }
}

class _EmptyUpcoming extends StatelessWidget {
  const _EmptyUpcoming();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Text('No upcoming reservations',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 48),
        Center(
          child: Text("Let's Play!",
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text('What would you like to do next?',
              style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(height: 24),
        _BigButton(
          label: 'Browse events',
          icon: Icons.campaign_outlined,
          onTap: () => context.go(Routes.events),
        ),
        const SizedBox(height: 12),
        _BigButton(
          label: 'Book a court',
          icon: Icons.add_circle_outline,
          onTap: () => context.go(Routes.book),
        ),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.inverseSurface,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: scheme.onInverseSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primary,
                child: Icon(icon, color: scheme.onPrimary, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

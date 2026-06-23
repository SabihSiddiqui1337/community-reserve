import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../amenities/data/amenity_repository.dart';
import '../data/reservation_repository.dart';
import '../domain/reservation.dart';
import 'reservation_detail_dialog.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Re-evaluate isUpcoming over time so a reservation that just ended moves
    // from Upcoming to History without a manual refresh.
    _ticker = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservations = ref.watch(myReservationsProvider);
    final amenities = ref.watch(amenitiesProvider).value ?? const [];

    String nameFor(String id) =>
        amenities.where((a) => a.id == id).firstOrNull?.name ?? 'Reservation';
    String typeFor(String id) =>
        amenities.where((a) => a.id == id).firstOrNull?.type ?? '';

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
            // Upcoming: soonest first (earliest → latest).
            final upcoming = list.where((r) => r.isUpcoming).toList()
              ..sort((a, b) => (a.startTime ?? DateTime(0))
                  .compareTo(b.startTime ?? DateTime(0)));
            // History: most recent first.
            final history = list.where((r) => !r.isUpcoming).toList()
              ..sort((a, b) => (b.startTime ?? DateTime(0))
                  .compareTo(a.startTime ?? DateTime(0)));
            return TabBarView(
              children: [
                upcoming.isEmpty
                    ? const _EmptyUpcoming()
                    : _BookingsList(
                        items: upcoming,
                        nameFor: nameFor,
                        typeFor: typeFor,
                        isHistory: false),
                history.isEmpty
                    ? const Center(child: Text('No past bookings.'))
                    : _BookingsList(
                        items: history,
                        nameFor: nameFor,
                        typeFor: typeFor,
                        isHistory: true),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({
    required this.items,
    required this.nameFor,
    required this.typeFor,
    required this.isHistory,
  });
  final List<Reservation> items;
  final String Function(String) nameFor;
  final String Function(String) typeFor;
  final bool isHistory;

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
        void open() => showReservationDetailDialog(context, r.id);
        // Every card opens the detail dialog — upcoming ones show the live
        // countdown/PIN/cancel flow, past ones show a summary + receipt.
        return Card(
          child: ListTile(
            onTap: open,
            leading: _BookingThumb(type: typeFor(r.amenityId), active: active),
            title: Text(nameFor(r.amenityId),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text([
              if (r.startTime != null)
                DateFormat('EEE, MMM d · h:mm a').format(r.startTime!),
              if (r.court != null) 'Court ${r.court}',
            ].join(' · ')),
            trailing: isHistory
                ? _HistoryTrailing(status: r.status)
                : _trailing(theme, r.status, active),
          ),
        );
      },
    );
  }
}

// A clear "live now" green, distinct from the monochrome theme.
const _activeGreen = Color(0xFF22C55E);

String? _imageForType(String type) => switch (type) {
      'pickleballCourt' => 'assets/images/pickleball.png',
      'basketball' => 'assets/images/basketball.png',
      _ => null,
    };

IconData _iconForType(String type) => switch (type) {
      'hall' => Icons.celebration_outlined,
      'pickleballCourt' => Icons.sports_tennis,
      'basketball' => Icons.sports_basketball,
      _ => Icons.event,
    };

/// Leading thumbnail: the sport photo when available, else an icon chip.
class _BookingThumb extends StatelessWidget {
  const _BookingThumb({required this.type, required this.active});
  final String type;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = _imageForType(type);
    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(image, height: 46, width: 46, fit: BoxFit.cover),
      );
    }
    return CircleAvatar(
      backgroundColor:
          active ? _activeGreen : theme.colorScheme.primaryContainer,
      child: Icon(active ? Icons.lock_open : _iconForType(type),
          color: active
              ? Colors.white
              : theme.colorScheme.onPrimaryContainer),
    );
  }
}

/// History card trailing: a "View details" button with the status beneath it.
class _HistoryTrailing extends StatelessWidget {
  const _HistoryTrailing({required this.status});
  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      ReservationStatus.completed => ('COMPLETED', _activeGreen),
      ReservationStatus.cancelled =>
        ('CANCELLED', theme.colorScheme.onSurfaceVariant),
      ReservationStatus.noShow => ('NO-SHOW', theme.colorScheme.error),
      ReservationStatus.expired =>
        ('EXPIRED', theme.colorScheme.onSurfaceVariant),
      _ => ('', theme.colorScheme.onSurfaceVariant),
    };
    // Plain text affordance (no button) — the whole card is the tap target,
    // so this shouldn't have its own hover/highlight.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('View Details',
            style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 11)),
      ],
    );
  }
}

Widget _trailing(ThemeData theme, ReservationStatus status, bool active) {
  if (active) {
    return Chip(
      label: const Text('Active',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: _activeGreen,
      side: BorderSide.none,
    );
  }
  switch (status) {
    case ReservationStatus.booked:
    case ReservationStatus.checkedIn:
      return const Icon(Icons.chevron_right);
    case ReservationStatus.completed:
      return const Text('COMPLETED',
          style: TextStyle(
              color: _activeGreen, fontWeight: FontWeight.w700, fontSize: 12));
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
          label: 'Browse Events',
          icon: Icons.campaign_outlined,
          onTap: () => context.go(Routes.events),
        ),
        const SizedBox(height: 12),
        _BigButton(
          label: 'Book a Court',
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
      color: scheme.surfaceContainerHigh,
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
                        color: scheme.onSurface,
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

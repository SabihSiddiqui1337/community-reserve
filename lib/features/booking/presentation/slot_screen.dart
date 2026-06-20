import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../../shared/money/money.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../reservations/data/reservation_repository.dart';
import '../../reservations/domain/reservation.dart';
import '../data/availability_repository.dart';
import '../domain/availability.dart';

/// Court-style availability + slot picker (IMG 1510 / 1513). Pick one or more
/// consecutive hours; a fully-booked hour shows a grey BOOKED block.
class SlotScreen extends ConsumerStatefulWidget {
  const SlotScreen({super.key, required this.amenityId});
  final String amenityId;

  @override
  ConsumerState<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends ConsumerState<SlotScreen> {
  DateTime _day = DateTime.now();
  final Set<int> _selected = {}; // indices into the day's visible slots
  bool _capHit = false;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  static const _maxHours = 2; // residents can book up to 2 consecutive hours

  /// Contiguous selection: extend at either end (up to [_maxHours]), shrink from
  /// an end, else reset.
  void _toggle(int index, int lastIndex) {
    setState(() {
      if (_selected.isEmpty) {
        _selected.add(index);
        return;
      }
      final min = _selected.reduce((a, b) => a < b ? a : b);
      final max = _selected.reduce((a, b) => a > b ? a : b);
      if (index == max + 1 || index == min - 1) {
        if (_selected.length >= _maxHours) {
          // At the 2-hour cap — ignore further extension.
          _capHit = true;
          return;
        }
        _selected.add(index);
      } else if (index == max && _selected.length > 1) {
        _selected.remove(index);
      } else if (index == min && _selected.length > 1) {
        _selected.remove(index);
      } else if (_selected.contains(index) && _selected.length == 1) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final amenity = ref.watch(amenityProvider(widget.amenityId));
    final community = ref.watch(activeCommunityProvider);
    final advanceDays = community.settings.advanceBookingDays;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.book),
        ),
        title: const Text('Book a Court'),
        centerTitle: true,
      ),
      body: amenity.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (a) {
          if (a == null) return const Center(child: Text('Not found'));
          final availability =
              ref.watch(dayAvailabilityProvider((amenityId: a.id, day: _day)));
          var slots = availability.maybeWhen(
            data: (busy) => computeDaySlots(a, _day, busy),
            orElse: () => <Slot>[],
          );
          // Only future times for today.
          if (_isToday(_day)) {
            final now = DateTime.now();
            slots = slots.where((s) => s.start.isAfter(now)).toList();
          }

          return Column(
            children: [
              _DateStrip(
                selected: _day,
                days: advanceDays,
                onSelect: (d) => setState(() {
                  _day = d;
                  _selected.clear();
                }),
              ),
              const Divider(height: 1),
              Expanded(
                child: availability.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : slots.isEmpty
                        ? const Center(child: Text('No more times today.'))
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: slots.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, i) => _SlotRow(
                              slot: slots[i],
                              selected: _selected.contains(i),
                              onTap: () {
                                _toggle(i, slots.length - 1);
                                if (_capHit) {
                                  _capHit = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('You can book up to 2 hours.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _selected.isEmpty
          ? null
          : _CheckoutBar(
              hours: _selected.length,
              priceCents: _priceForSelection(),
              onCheckout: () => _goCheckout(),
            ),
    );
  }

  int _priceForSelection() {
    final a = ref.read(amenityProvider(widget.amenityId)).value;
    return (a?.pricing.amountCents ?? 0) * _selected.length;
  }

  void _goCheckout() {
    final a = ref.read(amenityProvider(widget.amenityId)).value;
    if (a == null) return;

    // Gate on the active-reservation limit here (clear dialog), rather than
    // letting the server reject it with a toast after Reserve.
    final myRes = ref.read(myReservationsProvider).value ?? const [];
    final activeCount = myRes.where((r) => r.isUpcoming).length;
    final maxActive = ref
        .read(activeCommunityProvider)
        .settings
        .maxActiveReservationsPerUser;
    if (activeCount >= maxActive) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(Icons.event_busy,
              color: Theme.of(dialogContext).colorScheme.error),
          title: const Text('Reservation limit reached'),
          content: Text(
            'You already have $maxActive active reservation'
            '${maxActive == 1 ? '' : 's'}. Cancel one in My Bookings to book '
            'another.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
      return;
    }
    var slots = computeDaySlots(
        a,
        _day,
        ref
                .read(dayAvailabilityProvider((amenityId: a.id, day: _day)))
                .value ??
            const []);
    if (_isToday(_day)) {
      final now = DateTime.now();
      slots = slots.where((s) => s.start.isAfter(now)).toList();
    }
    final picked = _selected.map((i) => slots[i]).toList()
      ..sort((x, y) => x.start.compareTo(y.start));
    if (picked.isEmpty) return;
    final start = picked.first.start;
    final end = picked.last.end;
    context.go(Routes.bookCheckoutTo(
      a.id,
      start: start.toUtc().toIso8601String(),
      end: end.toUtc().toIso8601String(),
    ));
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip(
      {required this.selected, required this.days, required this.onSelect});
  final DateTime selected;
  final int days;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: days,
        itemBuilder: (context, i) {
          final d = DateTime(today.year, today.month, today.day + i);
          final isSel = d.day == selected.day && d.month == selected.month;
          final label = i == 0 ? 'Today' : DateFormat('EEE').format(d);
          return GestureDetector(
            onTap: () => onSelect(d),
            child: Container(
              width: 64,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSel
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color: isSel
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(DateFormat('M/d').format(d),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSel
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow(
      {required this.slot, required this.selected, required this.onTap});
  final Slot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final full = !slot.isAvailable;
    final availLabel = full
        ? 'BOOKED'
        : slot.capacity > 1
            ? '${slot.remaining} court${slot.remaining == 1 ? '' : 's'} available'
            : 'Available';

    return Material(
      color: selected ? theme.colorScheme.primary : Colors.transparent,
      child: InkWell(
        onTap: full ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  DateFormat('h:mm a').format(slot.start),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : full
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (full)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('BOOKED',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  full ? '' : availLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (!full)
                Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar(
      {required this.hours,
      required this.priceCents,
      required this.onCheckout});
  final int hours;
  final int priceCents;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.inverseSurface,
      child: InkWell(
        onTap: onCheckout,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Check out',
                        style: TextStyle(
                            color: scheme.onInverseSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: scheme.onInverseSurface),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$hours hr · ${Money.format(priceCents)}',
                  style: TextStyle(color: scheme.onInverseSurface.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

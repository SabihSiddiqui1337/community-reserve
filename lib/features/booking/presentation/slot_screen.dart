import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../../shared/money/money.dart';
import '../../../shared/widgets/app_snack.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../amenities/domain/amenity.dart';
import '../../community/application/tenant_providers.dart';
import '../../notifications/data/local_notification_service.dart';
import '../../reservations/data/reservation_repository.dart';
import '../../reservations/domain/reservation.dart';
import '../../waitlist/data/waitlist_repository.dart';
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
  bool _blocked = false; // tapped a non-adjacent slot while a 2-hr block is set
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool _limitDialogOpen = false;

  Future<void> _showLimitDialog(String body) async {
    if (_limitDialogOpen) return;
    _limitDialogOpen = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.timer_outlined,
            color: Theme.of(dialogContext).colorScheme.primary),
        title: const Text('Up to 2 hours'),
        content: Text(body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
    _limitDialogOpen = false;
  }

  /// When the Check-out bar first appears, nudge the list up so the slot you
  /// just tapped isn't hidden behind the bar.
  void _liftAboveBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        (_scroll.offset + 110).clamp(0.0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

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
        // A non-adjacent ("skipped") slot can't extend a consecutive block.
        if (_selected.length >= _maxHours) {
          // Don't wipe out a full 2-hour block on a stray tap — keep it and
          // explain instead.
          _blocked = true;
        } else {
          // Only a single hour was picked — nothing valuable to lose, so just
          // move the selection to the tapped slot.
          _selected
            ..clear()
            ..add(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final amenity = ref.watch(amenityProvider(widget.amenityId));
    final community = ref.watch(activeCommunityProvider);
    final advanceDays = community.settings.advanceBookingDays;
    final sportName = amenity.value?.name;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.book),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Book a Court', style: TextStyle(fontSize: 13)),
            if (sportName != null)
              Text(sportName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
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
            slots = slots
                .where((s) => s.end
                    .subtract(const Duration(minutes: 10))
                    .isAfter(now))
                .toList();
          }

          // Slots this user has already asked to be notified about.
          final waitlist = ref.watch(myWaitlistProvider).value ?? const [];
          final waitlistedStarts = <DateTime>{
            for (final w in waitlist)
              if (w.amenityId == a.id && w.desiredStart != null)
                w.desiredStart!,
          };

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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Select up to 2 consecutive hours',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: availability.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : slots.isEmpty
                        ? const Center(child: Text('No more times today.'))
                        : Builder(builder: (context) {
                            // Footer note with the closing time (skipped for
                            // 24-hour amenities).
                            final open24 =
                                a.openHour == 0 && a.closeHour == 24;
                            final count =
                                slots.length + (open24 ? 0 : 1);
                            return ListView.separated(
                              controller: _scroll,
                              padding: EdgeInsets.only(
                                  bottom: _selected.isEmpty ? 24 : 120),
                              itemCount: count,
                              separatorBuilder: (_, i) => i >= slots.length - 1
                                  ? const SizedBox.shrink()
                                  : const Divider(height: 1),
                              itemBuilder: (context, i) {
                                if (i == slots.length) {
                                  return _ClosingFooter(amenity: a);
                                }
                                return _SlotRow(
                                  slot: slots[i],
                                  selected: _selected.contains(i),
                                  waitlisted: waitlistedStarts
                                      .contains(slots[i].start),
                                  onNotify: () => _notify(slots[i]),
                                  onTap: () {
                                    final wasEmpty = _selected.isEmpty;
                                    _toggle(i, slots.length - 1);
                                    if (_capHit) {
                                      _capHit = false;
                                      _showLimitDialog(
                                          'You can book a maximum of 2 consecutive hours at a time.');
                                    }
                                    if (_blocked) {
                                      _blocked = false;
                                      _showLimitDialog(
                                          'Hours must be back-to-back. You can book up to 2 consecutive hours — tap a slot next to your current selection, or clear it first.');
                                    }
                                    if (wasEmpty && _selected.isNotEmpty) {
                                      _liftAboveBar();
                                    }
                                  },
                                );
                              },
                            );
                          }),
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

  /// Join the waitlist for a fully-booked slot so the user is notified the
  /// moment it frees up (server pings the FIFO waitlist on cancellation).
  Future<void> _notify(Slot slot) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    final community = ref.read(activeCommunityProvider);
    final amenity = ref.read(amenityProvider(widget.amenityId)).value;
    final time = DateFormat('h:mm a').format(slot.start);
    try {
      await ref.read(waitlistRepositoryProvider).join(
            communityId: cid,
            amenityId: widget.amenityId,
            desiredStart: slot.start,
            desiredEnd: slot.end,
          );

      // DEMO: also fire a local notification in ~5s so the deep-link flow can
      // be verified on-device without a real push backend. Remove this block
      // (and LocalNotifications) once real push is wired up.
      await LocalNotifications.scheduleDemoSlotOpen(
        title: '${amenity?.name ?? 'Your court'} is now available',
        body:
            'Your $time slot just opened up. Tap to book it before someone else grabs it.',
        route: Routes.bookSlotsTo(widget.amenityId),
        timezoneName: community.timezone,
      );

      if (mounted) {
        showSnack(
          context,
          "We'll notify you when the $time slot opens. (Demo: alert in ~5s — you can close the app.)",
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, "Couldn't set up the notification.");
      }
    }
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
      slots = slots
          .where(
              (s) => s.end.subtract(const Duration(minutes: 10)).isAfter(now))
          .toList();
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
  const _SlotRow({
    required this.slot,
    required this.selected,
    required this.onTap,
    required this.waitlisted,
    required this.onNotify,
  });
  final Slot slot;
  final bool selected;
  final VoidCallback onTap;
  final bool waitlisted;
  final VoidCallback onNotify;

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
                  full
                      ? (waitlisted ? "We'll notify you" : '')
                      : availLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : full && waitlisted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                    fontWeight:
                        full && waitlisted ? FontWeight.w600 : null,
                  ),
                ),
              ),
              if (full)
                // Bell: ask to be notified when this slot frees up.
                IconButton(
                  tooltip: waitlisted
                      ? "You'll be notified"
                      : 'Notify me when available',
                  onPressed: waitlisted ? null : onNotify,
                  icon: Icon(
                    waitlisted
                        ? Icons.notifications_active
                        : Icons.notification_add_outlined,
                    color: waitlisted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
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

/// A gentle closing-time note shown under the last slot of the day.
class _ClosingFooter extends StatelessWidget {
  const _ClosingFooter({required this.amenity});
  final Amenity amenity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final closeTime =
        TimeOfDay(hour: amenity.closeHour % 24, minute: 0).format(context);
    final isCourt = amenity.type == 'pickleballCourt' ||
        amenity.type == 'basketball';
    final word = isCourt ? 'Lights close' : 'Closes';
    final icon = isCourt ? Icons.lightbulb_outline : Icons.nightlight_round;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              '$word at $closeTime',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Check out',
                        style: TextStyle(
                            color: scheme.onInverseSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward,
                        size: 18, color: scheme.onInverseSurface),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '$hours hr · ${Money.format(priceCents)}',
                  style: TextStyle(
                      color: scheme.onInverseSurface.withValues(alpha: 0.80),
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

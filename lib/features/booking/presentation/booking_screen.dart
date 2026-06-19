import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../../shared/money/money.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../payments/data/payment_repository.dart';
import '../../reservations/data/reservation_repository.dart';
import '../../reservations/domain/reservation.dart';
import '../../waitlist/data/waitlist_repository.dart';
import '../domain/availability.dart';

/// Reservations for one amenity on one day — feeds the availability grid.
final _dayReservationsProvider = StreamProvider.family<List<Reservation>,
    ({String amenityId, DateTime day})>((ref, args) {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return Stream.value(const []);
  final dayStart = DateTime(args.day.year, args.day.month, args.day.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  return ref
      .watch(reservationRepositoryProvider)
      .watchForAmenityRange(cid, args.amenityId, dayStart, dayEnd);
});

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.amenityId});
  final String amenityId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _day = DateTime.now();
  bool _booking = false;

  Future<void> _book(Slot slot) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;

    final amenity = ref.read(amenityProvider(widget.amenityId)).value;
    final community = ref.read(activeCommunityProvider);
    final needsPayment = amenity != null &&
        amenity.pricing.isPaid &&
        community.featureFlags.paymentsEnabled;

    String? paymentId;
    if (needsPayment) {
      final pay = await showModalBottomSheet<bool>(
        context: context,
        builder: (_) => _PaymentSheet(
          amountCents: amenity.pricing.amountCents,
          currency: amenity.pricing.currency,
        ),
      );
      if (pay != true) return;
    }

    setState(() => _booking = true);
    try {
      if (needsPayment) {
        paymentId = await ref.read(paymentRepositoryProvider).createPayment(
              communityId: cid,
              amountCents: amenity.pricing.amountCents,
              currency: amenity.pricing.currency,
            );
      }
      final result =
          await ref.read(reservationRepositoryProvider).createReservation(
                communityId: cid,
                amenityId: widget.amenityId,
                start: slot.start,
                end: slot.end,
                paymentId: paymentId,
              );
      ref.read(pinCacheProvider.notifier).put(result.reservationId, result.pin);
      if (!mounted) return;
      context.go(Routes.reservationTo(result.reservationId));
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Booking failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  Future<void> _joinWaitlist(Slot slot) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    try {
      await ref.read(waitlistRepositoryProvider).join(
            communityId: cid,
            amenityId: widget.amenityId,
            desiredStart: slot.start,
            desiredEnd: slot.end,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Added to the waitlist — we'll notify you if it opens."),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not join the waitlist.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amenity = ref.watch(amenityProvider(widget.amenityId));
    final community = ref.watch(activeCommunityProvider);
    final advanceDays = community.settings.advanceBookingDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a slot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.amenityDetailTo(widget.amenityId)),
        ),
      ),
      body: amenity.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (a) {
          if (a == null) return const Center(child: Text('Not found'));
          final reservations = ref.watch(
              _dayReservationsProvider((amenityId: a.id, day: _day)));
          final slots = reservations.maybeWhen(
            data: (list) => computeDaySlots(a, _day, list),
            orElse: () => <Slot>[],
          );
          return Column(
            children: [
              _DayStrip(
                selected: _day,
                days: advanceDays,
                onSelect: (d) => setState(() => _day = d),
              ),
              const Divider(height: 1),
              Expanded(
                child: reservations.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.count(
                        crossAxisCount: 3,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: slots
                            .map((s) => _SlotTile(
                                  slot: s,
                                  busy: _booking,
                                  onTap: () => s.isAvailable
                                      ? _book(s)
                                      : _joinWaitlist(s),
                                ))
                            .toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip(
      {required this.selected, required this.days, required this.onSelect});
  final DateTime selected;
  final int days;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: days,
        itemBuilder: (context, i) {
          final d = DateTime(today.year, today.month, today.day + i);
          final isSel = d.day == selected.day && d.month == selected.month;
          return GestureDetector(
            onTap: () => onSelect(d),
            child: Container(
              width: 60,
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
                  Text(DateFormat('EEE').format(d),
                      style: TextStyle(
                          color: isSel
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                      style: TextStyle(
                          color: isSel
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentSheet extends StatelessWidget {
  const _PaymentSheet({required this.amountCents, required this.currency});
  final int amountCents;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.lock, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Secure checkout', style: theme.textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('TEST MODE', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Amount due', style: theme.textTheme.bodyMedium),
            Text(Money.format(amountCents, currency: currency),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Payments are stubbed in this build — no real charge is made. '
              'Stripe (Apple Pay / Google Pay / cards) drops in here later.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.payment),
              label: Text('Pay ${Money.format(amountCents, currency: currency)}'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile(
      {required this.slot, required this.busy, required this.onTap});
  final Slot slot;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = slot.isAvailable;
    return Material(
      color: available
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('h:mm a').format(slot.start),
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: available
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(
                available ? '${slot.remaining} open' : 'Waitlist',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: available
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


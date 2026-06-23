import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../../shared/money/money.dart';
import '../../../shared/widgets/app_snack.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/domain/app_user.dart';
import '../../community/application/tenant_providers.dart';
import '../../notifications/data/local_notification_service.dart';
import '../../payments/data/payment_repository.dart';
import '../../payments/domain/payment_method.dart';
import '../../payments/presentation/add_payment_sheet.dart';
import '../../payments/presentation/payment_methods_sheet.dart';
import '../../reservations/data/reservation_repository.dart';
import '../data/availability_repository.dart';

const _taxRate = 0.0825;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.amenityId,
    required this.start,
    required this.end,
  });
  final String amenityId;
  final DateTime start;
  final DateTime end;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int? _court; // null = Auto
  bool _busy = false;

  Future<void> _reserve(int subtotalCents, int totalCents,
      {String? paymentMethod, int? court}) async {
    final cid = ref.read(currentCommunityIdProvider);
    final community = ref.read(activeCommunityProvider);
    final amenity = ref.read(amenityProvider(widget.amenityId)).value;
    if (cid == null || amenity == null) return;

    final needsPayment =
        amenity.pricing.isPaid && community.featureFlags.paymentsEnabled;
    // No card on file but payment is required: collect one before reserving.
    if (needsPayment &&
        ref.read(currentUserProvider).value?.selectedCard == null) {
      final added = await showAddPaymentSheet(context, ref);
      if (added == null) return; // dismissed without adding a card
    }

    setState(() => _busy = true);
    try {
      String? paymentId;
      if (needsPayment) {
        paymentId = await ref.read(paymentRepositoryProvider).createPayment(
              communityId: cid,
              amountCents: totalCents,
              currency: amenity.pricing.currency,
            );
      }
      // Snapshot how it was paid for the receipt: the explicitly chosen method
      // (a picked card / Apple Pay / Google Pay), else the card on file.
      final card = ref.read(currentUserProvider).value?.selectedCard;
      final methodLabel = !needsPayment
          ? null
          : (paymentMethod ??
              (card != null ? '${card.brand} •••• ${card.last4}' : null));
      final res = await ref.read(reservationRepositoryProvider).createReservation(
            communityId: cid,
            amenityId: widget.amenityId,
            start: widget.start,
            end: widget.end,
            paymentId: paymentId,
            court: court ?? _court,
            paymentMethod: methodLabel,
          );
      ref.read(pinCacheProvider.notifier).put(res.reservationId, res.pin);
      // The slot is now taken — drop cached availability so it refetches fresh.
      ref.invalidate(dayAvailabilityProvider);
      // Remind the user to check in 10 minutes before the reservation starts.
      await LocalNotifications.scheduleCheckInReminder(
        reservationId: res.reservationId,
        amenityName: amenity.name,
        startLocal: widget.start,
        timezoneName: community.timezone,
      );
      if (mounted) {
        showSnack(context, 'Reservation confirmed!');
        context.go(Routes.myBookings);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        showError(context, e.message ?? 'Could not complete the reservation.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amenityAsync = ref.watch(amenityProvider(widget.amenityId));
    final user = ref.watch(currentUserProvider).value;
    final busy = ref
            .watch(dayAvailabilityProvider(
                (amenityId: widget.amenityId, day: widget.start)))
            .value ??
        const [];

    return amenityAsync.maybeWhen(
      orElse: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      data: (amenity) {
        if (amenity == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }
        // Bill only for usable time: the window [billedStart, end] where
        // billedStart = max(slotStart, now). A slot booked after it began is
        // charged only for the remaining minutes. The server recomputes this
        // authoritatively at creation.
        final now = DateTime.now();
        final billedStart = widget.start.isBefore(now) ? now : widget.start;
        final billedMinutes =
            widget.end.difference(billedStart).inMinutes.clamp(0, 1 << 31);
        final alreadyStarted = widget.start.isBefore(now) && billedMinutes > 0;
        // Free amenities never charge — ignore any stale price on the doc.
        final subtotal = amenity.pricing.isPaid
            ? (amenity.pricing.amountCents * billedMinutes / 60.0).round()
            : 0;
        final taxEnabled =
            ref.watch(activeCommunityProvider).settings.taxEnabled;
        final tax = taxEnabled ? (subtotal * _taxRate).round() : 0;
        final total = subtotal + tax;
        final capacity = amenity.capacity;

        // Per-hour line items for the FULL slot (the court's regular cost). When
        // the slot already started we still show the full price, then a prorated
        // "charged for the remaining minutes" line below.
        final segments = <(DateTime, DateTime, int)>[];
        var segStart = widget.start;
        while (segStart.isBefore(widget.end)) {
          var segEnd = segStart.add(const Duration(hours: 1));
          if (segEnd.isAfter(widget.end)) segEnd = widget.end;
          final mins = segEnd.difference(segStart).inMinutes;
          segments.add((
            segStart,
            segEnd,
            (amenity.pricing.amountCents * mins / 60.0).round(),
          ));
          segStart = segEnd;
        }

        final bookedCourts = <int>{
          for (final b in busy)
            if (b.court != null &&
                b.start.isBefore(widget.end) &&
                b.end.isAfter(widget.start))
              b.court!
        };

        // No "Auto" — always a specific court. Use the user's pick when it's
        // still free, otherwise the first available court.
        final availableCourts = [
          for (var c = 1; c <= capacity; c++)
            if (!bookedCourts.contains(c)) c,
        ];
        final effectiveCourt =
            (_court != null && availableCourts.contains(_court))
                ? _court
                : (availableCourts.isNotEmpty ? availableCourts.first : null);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Summary'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(Routes.bookSlotsTo(widget.amenityId)),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Center(
                child: Text(amenity.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              // Date + time of the booking.
              Text(DateFormat('EEEE, MMMM d').format(widget.start),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                '${DateFormat('h:mm a').format(widget.start)} – ${DateFormat('h:mm a').format(widget.end)}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (capacity > 1) ...[
                _CourtSelector(
                  capacity: capacity,
                  bookedCourts: bookedCourts,
                  selected: effectiveCourt,
                  onChanged: (c) => setState(() => _court = c),
                ),
                const SizedBox(height: 16),
              ],
              if (amenity.pricing.isPaid) ...[
                const Divider(),
                // Per-hour price breakdown, then subtotal + tax. (Total shows in
                // the pay bar at the bottom.)
                if (capacity > 1 && effectiveCourt != null)
                  _Line(
                    label: 'Court',
                    value: 'Court $effectiveCourt',
                    subtle: true,
                  ),
                for (final seg in segments)
                  _Line(
                    label:
                        '${DateFormat('h:mm a').format(seg.$1)} – ${DateFormat('h:mm a').format(seg.$2)}',
                    value: Money.format(seg.$3),
                    subtle: true,
                  ),
                // Slot already started → show the prorated charge for the
                // remaining minutes (the full price is shown above).
                if (alreadyStarted)
                  _Line(
                    label: 'Charged for remaining $billedMinutes min',
                    value: Money.format(subtotal),
                    subtle: true,
                    highlight: true,
                  ),
                const Divider(),
                _Line(label: 'Subtotal', value: Money.format(subtotal)),
                if (taxEnabled)
                  _Line(label: 'Tax (8.25%)', value: Money.format(tax)),
                const SizedBox(height: 16),
              ] else ...[
                // Free amenity — no charge, no breakdown.
                const Divider(),
                _Line(label: 'Price', value: 'Free'),
                const SizedBox(height: 16),
              ],
              const _Rules(),
              const SizedBox(height: 100),
            ],
          ),
          bottomNavigationBar: _PayBar(
            totalCents: total,
            free: total == 0,
            card: user?.selectedCard,
            busy: _busy,
            onReserve: () => _reserve(subtotal, total, court: effectiveCourt),
            onOtherPay: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (sheetContext) => _SelectPaymentMethodSheet(
                onPick: (method) {
                  Navigator.pop(sheetContext);
                  _reserve(subtotal, total,
                      paymentMethod: method, court: effectiveCourt);
                },
              ),
            ),
            onChange: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: false,
              builder: (_) => const PaymentMethodsSheet(),
            ),
          ),
        );
      },
    );
  }
}

class _CourtSelector extends StatelessWidget {
  const _CourtSelector({
    required this.capacity,
    required this.bookedCourts,
    required this.selected,
    required this.onChanged,
  });
  final int capacity;
  final Set<int> bookedCourts;
  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_tennis, size: 20),
          const SizedBox(width: 12),
          const Text('Court'),
          const SizedBox(width: 12),
          // isExpanded makes the button fill the row, so the popup menu is wide
          // enough to show "· Booked" in full (no clipping), while the closed
          // button keeps a clean, right-aligned "Court N" via selectedItemBuilder.
          Expanded(
            child: DropdownButton<int>(
              value: selected,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              focusColor: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              selectedItemBuilder: (context) => [
                for (var c = 1; c <= capacity; c++)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Court $c',
                        style: const TextStyle(color: Colors.white)),
                  ),
              ],
              items: [
                // No "Auto" — pick a specific court. Booked courts are disabled.
                for (var c = 1; c <= capacity; c++)
                  DropdownMenuItem(
                    value: c,
                    enabled: !bookedCourts.contains(c),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Court $c',
                            style: TextStyle(
                              color: bookedCourts.contains(c)
                                  ? theme.colorScheme.onSurfaceVariant
                                  : Colors.white,
                            )),
                        if (bookedCourts.contains(c)) ...[
                          const SizedBox(width: 6),
                          Text('· Booked',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              )),
                        ],
                      ],
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(
      {required this.label,
      required this.value,
      this.subtle = false,
      this.highlight = false});
  final String label;
  final String value;

  /// Breakdown rows (per-hour / court) use a lighter, denser style than the
  /// Subtotal / Tax rows.
  final bool subtle;

  /// Draws the row in the accent colour (used for the prorated charge line).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight
        ? theme.colorScheme.primary
        : (subtle ? theme.colorScheme.onSurfaceVariant : null);
    final base = (subtle ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)
        ?.copyWith(color: color);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: subtle ? 5 : 12),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: highlight
                      ? base?.copyWith(fontWeight: FontWeight.w600)
                      : base)),
          const SizedBox(width: 12),
          Text(
            value,
            style: (subtle && !highlight)
                ? base
                : base?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _Rules extends StatelessWidget {
  const _Rules();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reservation policy',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          'All players are subject to no-show and overstay fees. Please arrive '
          'on time and vacate the court promptly at the end of your reservation '
          'to avoid charges.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PayBar extends StatelessWidget {
  const _PayBar({
    required this.totalCents,
    required this.card,
    required this.busy,
    required this.onReserve,
    required this.onChange,
    required this.onOtherPay,
    this.free = false,
  });
  final int totalCents;
  final PaymentMethod? card;
  final bool busy;
  final VoidCallback onReserve;
  final VoidCallback onChange;
  final VoidCallback onOtherPay;

  /// No charge — show "Free" and hide the card / "other ways to pay" UI.
  final bool free;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Total', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(free ? 'Free' : Money.format(totalCents),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            if (!free) ...[
              const SizedBox(height: 8),
              // Selected card + Change
              Row(
                children: [
                  Icon(Icons.credit_card,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card != null
                          ? '${card!.brand}  •••• ${card!.last4}'
                          : 'No card on file',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(onPressed: onChange, child: const Text('Change')),
                ],
              ),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: busy ? null : onReserve,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Reserve'),
            ),
            if (!free) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: busy ? null : onOtherPay,
                child: const Text('Other ways to pay'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Select Payment Method" picker: every saved card plus Apple Pay / Google
/// Pay. Tapping a method pays with it (snapshotted on the receipt as "Paid
/// with …"). Apple/Google Pay show the backing card's last 4.
class _SelectPaymentMethodSheet extends ConsumerWidget {
  const _SelectPaymentMethodSheet({required this.onPick});

  /// Called with the method label to snapshot, e.g. "Visa •••• 9672" or
  /// "Apple Pay •••• 9293".
  final void Function(String method) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final cards = user?.paymentMethods ?? const <PaymentMethod>[];
    final backingLast4 =
        user?.selectedCard?.last4 ?? (cards.isNotEmpty ? cards.first.last4 : '••••');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Center(
                    child: Text('Select Payment Method',
                        style: theme.textTheme.titleLarge),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Saved cards.
            for (final c in cards)
              _MethodRow(
                icon: Icons.credit_card,
                label: '${c.brand} •••• ${c.last4}',
                selected: c.id == user?.selectedCardId,
                onTap: () => onPick('${c.brand} •••• ${c.last4}'),
              ),
            if (cards.isNotEmpty) const SizedBox(height: 4),
            // Wallets.
            _MethodRow(
              icon: Icons.apple,
              label: 'Apple Pay',
              trailing: '•••• $backingLast4',
              onTap: () => onPick('Apple Pay •••• $backingLast4'),
            ),
            _MethodRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Google Pay',
              trailing: '•••• $backingLast4',
              onTap: () => onPick('Google Pay •••• $backingLast4'),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text('Demo — no real charge is made.',
                  style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable payment-method row in the picker.
class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(label, style: theme.textTheme.titleMedium),
                const Spacer(),
                if (trailing != null)
                  Text(trailing!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

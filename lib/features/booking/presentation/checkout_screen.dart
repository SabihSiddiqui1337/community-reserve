import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../../shared/money/money.dart';
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

  Future<void> _reserve(int subtotalCents, int totalCents) async {
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
      final res = await ref.read(reservationRepositoryProvider).createReservation(
            communityId: cid,
            amenityId: widget.amenityId,
            start: widget.start,
            end: widget.end,
            paymentId: paymentId,
            court: _court,
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
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation confirmed!')));
        context.go(Routes.myBookings);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Failed')));
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
        final hours =
            widget.end.difference(widget.start).inMinutes / 60.0;
        final subtotal = (amenity.pricing.amountCents * hours).round();
        final tax = (subtotal * _taxRate).round();
        final total = subtotal + tax;
        final capacity = amenity.capacity;

        final bookedCourts = <int>{
          for (final b in busy)
            if (b.court != null &&
                b.start.isBefore(widget.end) &&
                b.end.isAfter(widget.start))
              b.court!
        };

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEEE, MMMM d').format(widget.start),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          '${DateFormat('h:mm a').format(widget.start)} – ${DateFormat('h:mm a').format(widget.end)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(Money.format(subtotal),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              if (capacity > 1) ...[
                _CourtSelector(
                  capacity: capacity,
                  bookedCourts: bookedCourts,
                  selected: _court,
                  onChanged: (c) => setState(() => _court = c),
                ),
                const SizedBox(height: 20),
              ],
              const Divider(),
              _Line(label: 'Subtotal', value: Money.format(subtotal)),
              const Divider(),
              const SizedBox(height: 12),
              const _Rules(),
              const SizedBox(height: 12),
              const Divider(),
              _Line(label: 'Tax (8.25%)', value: Money.format(tax)),
              const SizedBox(height: 100),
            ],
          ),
          bottomNavigationBar: _PayBar(
            totalCents: total,
            card: user?.selectedCard,
            busy: _busy,
            onReserve: () => _reserve(subtotal, total),
            onOtherPay: () => showModalBottomSheet<void>(
              context: context,
              builder: (sheetContext) => _OtherWaysToPaySheet(
                onPay: () {
                  Navigator.pop(sheetContext);
                  _reserve(subtotal, total);
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
          const Spacer(),
          DropdownButton<int?>(
            value: selected,
            underline: const SizedBox.shrink(),
            focusColor: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            items: [
              const DropdownMenuItem(value: null, child: Text('Auto')),
              for (var c = 1; c <= capacity; c++)
                DropdownMenuItem(
                  value: c,
                  enabled: !bookedCourts.contains(c),
                  child: Text(
                    bookedCourts.contains(c) ? 'Court $c (booked)' : 'Court $c',
                    style: bookedCourts.contains(c)
                        ? TextStyle(color: theme.colorScheme.outline)
                        : null,
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
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
  });
  final int totalCents;
  final PaymentMethod? card;
  final bool busy;
  final VoidCallback onReserve;
  final VoidCallback onChange;
  final VoidCallback onOtherPay;

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
                Text(Money.format(totalCents),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
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
            const SizedBox(height: 4),
            TextButton(
              onPressed: busy ? null : onOtherPay,
              child: const Text('Other ways to pay'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet offering Apple Pay / Google Pay (placeholders — same stubbed flow).
class _OtherWaysToPaySheet extends StatelessWidget {
  const _OtherWaysToPaySheet({required this.onPay});
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text('Other ways to pay',
                  style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 20),
            // Apple Pay
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: onPay,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.apple, size: 24),
                label: const Text('Pay',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            // Google Pay
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: onPay,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color(0xFFDADCE0)),
                ),
                icon: const Icon(Icons.account_balance_wallet_outlined,
                    size: 22),
                label: const Text('Google Pay',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
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

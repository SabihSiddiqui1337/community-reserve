import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/money/money.dart';
import '../../../shared/widgets/app_snack.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../amenities/domain/amenity.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/domain/app_user.dart';
import '../../community/application/tenant_providers.dart';
import '../data/reservation_repository.dart';
import '../domain/reservation.dart';

/// PIN/QR become visible this many minutes before the reservation starts.
const _pinLeadMinutes = 10;

/// The full booking charge in cents for a reservation: the amenity's per-hour
/// price × the booked duration (in hours). Returns 0 when the amenity is free
/// or the times are missing.
int _chargeCents(Amenity? amenity, Reservation r) {
  if (amenity == null || !amenity.pricing.isPaid) return 0;
  final start = r.startTime;
  final end = r.endTime;
  if (start == null || end == null) return 0;
  final minutes = end.difference(start).inMinutes;
  if (minutes <= 0) return 0;
  return (amenity.pricing.amountCents * (minutes / 60.0)).round();
}

/// Sales-tax rate applied at checkout (matches the booking flow).
const _kTaxRate = 0.0825;

/// Subtotal in cents — the booking-time snapshot when present, else recomputed
/// from the amenity per-hour price (older docs predating the snapshot).
int _subtotalCents(Amenity? amenity, Reservation r) =>
    r.subtotalCents ?? _chargeCents(amenity, r);

/// Tax in cents — the booking-time snapshot when present (0 means tax was off
/// at booking), else recomputed from the subtotal.
int _taxCents(Amenity? amenity, Reservation r) =>
    r.taxCents ?? (_subtotalCents(amenity, r) * _kTaxRate).round();

/// The full amount paid — subtotal + tax — in cents (from the snapshot).
int _totalCents(Amenity? amenity, Reservation r) {
  final subtotal = _subtotalCents(amenity, r);
  if (subtotal == 0) return 0;
  return subtotal + _taxCents(amenity, r);
}

/// Client-side mirror of the server's prorated cancellation: keep the used
/// fraction of time, refund the rest while preserving the booking-time tax
/// decision. Returns (chargedCents, refundCents) in cents.
({int charged, int refund}) _proration(Amenity? amenity, Reservation r,
    {DateTime? asOf}) {
  final subtotal = _subtotalCents(amenity, r);
  final tax = _taxCents(amenity, r);
  final total = subtotal + tax;
  final start = r.startTime;
  final end = r.endTime;
  final at = asOf ?? DateTime.now();
  if (total == 0 || start == null || end == null) {
    return (charged: 0, refund: total);
  }
  // Proration is over the BILLED window [billedStart, end] where
  // billedStart = max(slotStart, bookingTime). A slot booked after it began was
  // only charged for the remaining minutes, so the used fraction is measured
  // against that window. Mirrors cancelReservation.ts.
  final createdAt = r.createdAt;
  final billedStart =
      (createdAt != null && createdAt.isAfter(start)) ? createdAt : start;
  // Before the billed window starts → full refund, nothing charged.
  if (!at.isAfter(billedStart)) return (charged: 0, refund: total);

  final billedMinutes = end.difference(billedStart).inMinutes.clamp(1, 1 << 31);
  final elapsedMinutes = at.difference(billedStart).inMinutes;
  final usedFraction = (elapsedMinutes / billedMinutes).clamp(0.0, 1.0);
  final keptSubtotal = (subtotal * usedFraction).round();
  final keptTax = (keptSubtotal * (tax / (subtotal == 0 ? 1 : subtotal))).round();
  final charged = keptSubtotal + keptTax;
  return (charged: charged, refund: total - charged);
}

/// A reservation is "past" once it is no longer live/upcoming — i.e. completed,
/// cancelled, no-show, expired, or simply ended.
bool _isPast(Reservation r) => !r.isUpcoming;

/// Open the reservation detail as a modal dialog (with an X to close).
Future<void> showReservationDetailDialog(
    BuildContext context, String reservationId) {
  return showDialog<void>(
    context: context,
    builder: (_) => ReservationDetailDialog(reservationId: reservationId),
  );
}

class ReservationDetailDialog extends ConsumerStatefulWidget {
  const ReservationDetailDialog({super.key, required this.reservationId});
  final String reservationId;

  @override
  ConsumerState<ReservationDetailDialog> createState() =>
      _ReservationDetailDialogState();
}

class _ReservationDetailDialogState
    extends ConsumerState<ReservationDetailDialog> {
  Timer? _ticker;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _checkIn(Reservation r) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    setState(() => _busy = true);
    try {
      final res = await ref.read(reservationRepositoryProvider).validateAccess(
            communityId: cid,
            reservationId: r.id,
          );
      if (!mounted) return;
      final ok = res['valid'] == true;
      if (ok) {
        // Stash the freshly-issued PIN so the panel shows the real number.
        final pin = res['pin'] as String?;
        if (pin != null) {
          ref.read(pinCacheProvider.notifier).put(r.id, pin);
        }
        // No success toast — the PIN panel appearing is the confirmation.
      } else {
        showSnack(context, 'Access denied: ${res['reason']}');
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        showSnack(context, e.message ?? 'Failed');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(Reservation r) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;

    // Prorated refund preview (mirrors the server). Before start the whole
    // charge comes back; at/after start the used minutes are kept. For free
    // amenities nothing was charged. The server recomputes authoritatively.
    final amenity = ref.read(amenityProvider(r.amenityId)).value;
    final paid = amenity?.pricing.isPaid ?? false;
    final total = _totalCents(amenity, r);
    final proration = _proration(amenity, r);
    final refundEstimate = proration.refund;
    final chargedEstimate = proration.charged;
    final hasRefund = paid && total > 0;

    // A cancellation only counts once the reservation has started. Compute
    // whether we're at/after start and, if so, how many late cancellations the
    // resident has left (allowance − already-counted), floored at zero.
    final started = r.startTime != null && !DateTime.now().isBefore(r.startTime!);
    // "Used" minutes are measured over the billed window [billedStart, end]
    // (billedStart = max(start, bookingTime)), matching the proration above.
    final billedStartForBanner =
        (r.startTime != null && r.createdAt != null && r.createdAt!.isAfter(r.startTime!))
            ? r.createdAt!
            : r.startTime;
    final usedMinutes = (started && billedStartForBanner != null)
        ? DateTime.now().difference(billedStartForBanner).inMinutes.clamp(0, 1 << 31)
        : 0;
    final community = ref.read(activeCommunityProvider);
    final membership = ref.read(currentMembershipProvider);
    final remaining = (community.settings.cancellationAllowance -
            (membership?.cancellationCount ?? 0))
        .clamp(0, 1 << 31);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        return AlertDialog(
          title: const Text('Cancel Reservation?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Big, bold refund amount (or a clear "free" message).
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: dialogTheme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (hasRefund) ...[
                      Text(
                        Money.format(refundEstimate),
                        style: dialogTheme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dialogTheme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "You'll be refunded this amount.",
                        style: dialogTheme.textTheme.bodyMedium,
                      ),
                      if (started && chargedEstimate > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: dialogTheme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "You've used ~$usedMinutes min, so you're charged "
                            '${Money.format(chargedEstimate)} (incl. tax). '
                            "You'll be refunded ${Money.format(refundEstimate)}.",
                            textAlign: TextAlign.center,
                            style: dialogTheme.textTheme.bodySmall?.copyWith(
                                color:
                                    dialogTheme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ] else ...[
                      Icon(Icons.savings_outlined,
                          size: 32,
                          color: dialogTheme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(
                        'No payment was charged.',
                        style: dialogTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                started
                    ? 'Cancelling now ends your reservation.'
                    : 'Cancelling before the start time is free.',
                textAlign: TextAlign.center,
                style: dialogTheme.textTheme.bodySmall
                    ?.copyWith(color: dialogTheme.colorScheme.onSurfaceVariant),
              ),
              if (started) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: dialogTheme.colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: 'A cancellation only counts if made after the '
                            'reservation start time.',
                        child: Icon(
                          Icons.info_outline,
                          size: 20,
                          color: dialogTheme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This will count toward your booking cancellations. '
                          'You have $remaining left.',
                          style: dialogTheme.textTheme.bodySmall?.copyWith(
                            color: dialogTheme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Keep'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: dialogTheme.colorScheme.error),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Cancel it'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    // The confirm dialog has already popped (synchronous Navigator.pop above),
    // so the UI dismisses immediately — the server call runs after.
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(reservationRepositoryProvider)
          .cancel(communityId: cid, reservationId: r.id);
      if (mounted) {
        Navigator.of(context).pop(); // close the detail dialog
        showSnack(context, 'Reservation cancelled.');
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        showError(context, e.message ?? 'Cancel failed');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reservation = ref.watch(reservationProvider(widget.reservationId));
    final pinCache = ref.watch(pinCacheProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Reservation',
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: reservation.when(
                loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Error: $e')),
                data: (r) {
                  if (r == null) {
                    return const Padding(
                        padding: EdgeInsets.all(24), child: Text('Not found'));
                  }
                  final amenity = ref.watch(amenityProvider(r.amenityId)).value;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: _Body(
                      reservation: r,
                      amenity: amenity,
                      amenityName: amenity?.name ?? 'Amenity',
                      pin: pinCache[r.id],
                      busy: _busy,
                      onCheckIn: () => _checkIn(r),
                      onCancel: () => _cancel(r),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.reservation,
    required this.amenity,
    required this.amenityName,
    required this.pin,
    required this.busy,
    required this.onCheckIn,
    required this.onCancel,
  });

  final Reservation reservation;
  final Amenity? amenity;
  final String amenityName;
  final String? pin;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    // Past reservations get a static summary + payment outcome instead of the
    // live countdown / PIN / cancel controls.
    if (_isPast(r)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoCard(reservation: r, amenityName: amenityName),
          const SizedBox(height: 14),
          _PaymentOutcome(reservation: r, amenity: amenity),
        ],
      );
    }

    final theme = Theme.of(context);
    final start = r.startTime;
    final end = r.endTime;
    final now = DateTime.now();

    final liveStatus = r.status == ReservationStatus.booked ||
        r.status == ReservationStatus.checkedIn;
    final pinOpensAt = start?.subtract(const Duration(minutes: _pinLeadMinutes));
    final accessOpen = liveStatus &&
        start != null &&
        end != null &&
        now.isAfter(pinOpensAt!) &&
        now.isBefore(end);
    final active = r.isActiveNow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(reservation: r, amenityName: amenityName),
        const SizedBox(height: 14),
        _Countdown(
            start: start,
            end: end,
            active: active,
            checkedIn: r.status == ReservationStatus.checkedIn),
        const SizedBox(height: 14),
        if (accessOpen && r.status == ReservationStatus.checkedIn) ...[
          // Checked in → reveal the PIN (no QR/barcode anymore).
          _AccessPanel(pin: pin),
        ] else if (accessOpen && r.status == ReservationStatus.booked) ...[
          // Within the 10-min window → can check in now; PIN appears only after.
          FilledButton.icon(
            onPressed: busy ? null : onCheckIn,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.lock_open),
            label: const Text('Check in'),
          ),
          const SizedBox(height: 8),
          Text(
            'Your PIN appears here once you check in.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ] else if (liveStatus &&
            pinOpensAt != null &&
            now.isBefore(pinOpensAt)) ...[
          // Genuinely before the access window opens (and not ended).
          _LockedAccessCard(pinOpensAt: pinOpensAt),
        ],
        // Receipt for the booking (subtotal + tax + total paid).
        const SizedBox(height: 14),
        _PaymentOutcome(reservation: r, amenity: amenity),
        // Cancel is allowed only before check-in. Once checked in / code used,
        // it's hidden.
        if (r.status == ReservationStatus.booked && r.isUpcoming) ...[
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: busy ? null : onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            icon: const Icon(Icons.close),
            label: const Text('Cancel reservation'),
          ),
        ],
      ],
    );
  }
}

/// The amenity name + status + date/time/court summary card. Shared by the
/// live and past variants of the dialog.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.reservation, required this.amenityName});
  final Reservation reservation;
  final String amenityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = reservation;
    final start = r.startTime;
    final end = r.endTime;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(amenityName,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              _StatusChip(status: r.status),
            ],
          ),
          const SizedBox(height: 10),
          if (start != null)
            _InfoLine(
                icon: Icons.event,
                text: DateFormat('EEEE, MMMM d').format(start)),
          if (start != null && end != null)
            _InfoLine(
              icon: Icons.schedule,
              text:
                  '${DateFormat('h:mm a').format(start)} – ${DateFormat('h:mm a').format(end)}',
            ),
          if (r.court != null)
            _InfoLine(icon: Icons.sports_tennis, text: 'Court ${r.court}'),
        ],
      ),
    );
  }
}

/// Payment outcome for a PAST reservation, derived from its status + whether a
/// payment existed (`paymentId`) + the amenity charge (per-hour × hours).
/// A full booking receipt for a past reservation: subtotal, tax, total paid,
/// and (for cancellations) a refunded row + net. Keeps the lime accent.
class _PaymentOutcome extends ConsumerWidget {
  const _PaymentOutcome({required this.reservation, required this.amenity});
  final Reservation reservation;
  final Amenity? amenity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = reservation;
    final subtotal = _subtotalCents(amenity, r);
    // What it was paid with — the snapshot on the booking, else the user's
    // current card on file. Apple/Google Pay always shows the backing card's
    // last 4 too.
    final card = ref.watch(currentUserProvider).value?.selectedCard;
    var paidWith = r.paymentMethod ??
        (card != null ? '${card.brand} •••• ${card.last4}' : null);
    if (paidWith != null && card != null && !paidWith.contains('••••')) {
      paidWith = '$paidWith •••• ${card.last4}';
    }
    // Paid is decided by the booking's OWN record (a payment + a charged
    // amount), not the amenity's current price — so a booking still shows its
    // receipt even if the amenity later became free.
    final wasPaid = r.paymentId != null && subtotal > 0;

    // No charge ever happened — show a clean note instead of an invoice.
    if (!wasPaid) {
      final isFree = !(amenity?.pricing.isPaid ?? false);
      final isTerminal = r.status == ReservationStatus.cancelled ||
          r.status == ReservationStatus.noShow ||
          r.status == ReservationStatus.expired;

      // Free booking (active/upcoming/completed): show a clear "Free" receipt so
      // it's easy to track in both Upcoming and History.
      if (isFree && !isTerminal) {
        final lime = theme.colorScheme.primary;
        return _ReceiptCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: lime, size: 20),
                  const SizedBox(width: 8),
                  Text('RECEIPT',
                      style: TextStyle(
                          letterSpacing: 1.2,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: lime)),
                ],
              ),
              const SizedBox(height: 16),
              _ReceiptRow(label: 'Price', value: 'Free'),
              const SizedBox(height: 12),
              Divider(color: theme.colorScheme.outlineVariant, height: 1),
              const SizedBox(height: 12),
              _ReceiptRow(label: 'Total', value: 'Free', strong: true),
            ],
          ),
        );
      }

      final msg = switch (r.status) {
        ReservationStatus.cancelled => isFree
            ? 'Cancelled — this booking was free.'
            : 'Cancelled — no payment was charged.',
        ReservationStatus.noShow => 'No-show — no payment was charged.',
        ReservationStatus.expired => 'Expired — no payment was charged.',
        _ => 'No payment was charged.',
      };
      return _ReceiptCard(
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
                child: Text(msg, style: theme.textTheme.bodyMedium)),
          ],
        ),
      );
    }

    final tax = _taxCents(amenity, r);
    final total = subtotal + tax;
    final refunded = r.status == ReservationStatus.cancelled;
    // Prorated refund as of the cancellation time (snapshot-aware). Cancelling
    // before start refunds the full total; at/after start keeps the used part.
    final proration = _proration(amenity, r, asOf: r.cancelledAt);
    final refundAmount = proration.refund;
    final netCharged = total - refundAmount;
    final lime = theme.colorScheme.primary;

    // Per-hour breakdown (mirrors the checkout Order Summary). Split the booked
    // window into hour segments and distribute the paid subtotal across them so
    // the rows always sum exactly to Subtotal (last segment takes any remainder).
    final segments = <(DateTime, DateTime, int)>[];
    final start = r.startTime;
    final end = r.endTime;
    if (start != null && end != null && end.isAfter(start)) {
      final totalMins = end.difference(start).inMinutes;
      var segStart = start;
      var allocated = 0;
      while (segStart.isBefore(end)) {
        var segEnd = segStart.add(const Duration(hours: 1));
        if (segEnd.isAfter(end)) segEnd = end;
        final mins = segEnd.difference(segStart).inMinutes;
        final isLast = !segEnd.isBefore(end);
        final cents =
            isLast ? subtotal - allocated : (subtotal * mins / totalMins).round();
        allocated += cents;
        segments.add((segStart, segEnd, cents));
        segStart = segEnd;
      }
    }
    final showCourt = (amenity?.capacity ?? 1) > 1 && r.court != null;

    return _ReceiptCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: lime, size: 20),
              const SizedBox(width: 8),
              Text('RECEIPT',
                  style: TextStyle(
                      letterSpacing: 1.2,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: lime)),
            ],
          ),
          const SizedBox(height: 16),
          if (showCourt) ...[
            _ReceiptRow(label: 'Court', value: 'Court ${r.court}'),
            const SizedBox(height: 9),
          ],
          for (final seg in segments) ...[
            _ReceiptRow(
              label:
                  '${DateFormat('h:mm a').format(seg.$1)} – ${DateFormat('h:mm a').format(seg.$2)}',
              value: Money.format(seg.$3),
            ),
            const SizedBox(height: 9),
          ],
          if (showCourt || segments.isNotEmpty) ...[
            Divider(color: theme.colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 12),
          ],
          _ReceiptRow(label: 'Subtotal', value: Money.format(subtotal)),
          if (tax > 0) ...[
            const SizedBox(height: 9),
            _ReceiptRow(label: 'Tax (8.25%)', value: Money.format(tax)),
          ],
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 12),
          _ReceiptRow(
              label: 'Total paid', value: Money.format(total), strong: true),
          if (refunded) ...[
            const SizedBox(height: 12),
            _ReceiptRow(
              label: 'Refunded',
              value: '−${Money.format(refundAmount)}',
              strong: true,
              valueColor: lime,
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 12),
            _ReceiptRow(
                label: 'Net charged',
                value: Money.format(netCharged),
                strong: true),
            const SizedBox(height: 10),
            Text(
                netCharged > 0
                    ? 'This booking was cancelled after it started, so the '
                        'used time was charged and the rest refunded.'
                    : 'This booking was cancelled and fully refunded.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ] else if (r.status == ReservationStatus.noShow) ...[
            const SizedBox(height: 10),
            Text('Charged as a no-show.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error)),
          ],
          if (paidWith != null) ...[
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              // "Discover •••• 9293" → method "Discover", digits "•••• 9293".
              final parts = paidWith!.split(' •••• ');
              final method = parts.first;
              final digits = parts.length > 1 ? '•••• ${parts[1]}' : null;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.credit_card,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('Paid with',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(method,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      if (digits != null)
                        Text(digits,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// Card shell used by the receipt (lime-tinted border to keep the accent).
class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.30)),
      ),
      child: child,
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final bool strong;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: strong
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant,
      fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
    );
    final valueStyle = (strong
            ? theme.textTheme.titleMedium
            : theme.textTheme.bodyMedium)
        ?.copyWith(
      fontWeight: strong ? FontWeight.bold : FontWeight.w500,
      color: valueColor ?? theme.colorScheme.onSurface,
    );
    return Row(
      children: [
        Text(label, style: labelStyle),
        const Spacer(),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown(
      {required this.start,
      required this.end,
      required this.active,
      required this.checkedIn});
  final DateTime? start;
  final DateTime? end;
  final bool active;
  final bool checkedIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final running = (checkedIn || active) && end != null && now.isBefore(end!);
    String label;
    String value;
    IconData icon;
    if (running) {
      // After check-in / while live: show time left in the reservation.
      label = 'Time remaining';
      value = _fmt(end!.difference(now));
      icon = Icons.timelapse;
    } else if (start != null && start!.isAfter(now)) {
      label = 'Starts in';
      value = _fmt(start!.difference(now));
      icon = Icons.hourglass_top;
    } else {
      label = 'Status';
      value = 'Ended';
      icon = Icons.check_circle_outline;
    }
    // Compact pill: small label on the left, medium mono time on the right.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(label.toUpperCase(),
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(value,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _LockedAccessCard extends StatelessWidget {
  const _LockedAccessCard({required this.pinOpensAt});
  final DateTime? pinOpensAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final at = pinOpensAt != null
        ? DateFormat('h:mm a').format(pinOpensAt!)
        : 'shortly before start';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_clock, color: theme.colorScheme.primary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Access locked', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Your PIN will show $_pinLeadMinutes minutes before your '
                  'reservation starts — at $at.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessPanel extends StatelessWidget {
  const _AccessPanel({required this.pin});
  final String? pin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: Column(
        children: [
          Text('YOUR ENTRY PIN',
              style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary)),
          const SizedBox(height: 12),
          Text(
            pin ?? '••••',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 10,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pin == null ? 'Fetching your PIN…' : 'Enter this PIN at the door',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ReservationStatus.booked => ('Booked', Colors.blue),
      ReservationStatus.checkedIn => ('Checked in', Colors.green),
      ReservationStatus.completed => ('Completed', Color(0xFF22C55E)),
      ReservationStatus.noShow => ('No-show', Colors.red),
      ReservationStatus.cancelled => ('Cancelled', Colors.grey),
      ReservationStatus.expired => ('Expired', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

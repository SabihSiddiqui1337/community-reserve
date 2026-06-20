import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../amenities/data/amenity_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../data/reservation_repository.dart';
import '../domain/reservation.dart';

/// PIN/QR become visible this many minutes before the reservation starts.
const _pinLeadMinutes = 10;

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
            qrToken: r.qrToken,
          );
      if (!mounted) return;
      final ok = res['valid'] == true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(ok ? 'Checked in — enjoy!' : 'Access denied: ${res['reason']}'),
      ));
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Failed')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(Reservation r) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: const Text(
            'Cancelling close to the start time may count as a no-show.'),
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
                      backgroundColor:
                          Theme.of(dialogContext).colorScheme.error),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Cancel it'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(reservationRepositoryProvider)
          .cancel(communityId: cid, reservationId: r.id);
      if (mounted) {
        Navigator.of(context).pop(); // close the detail dialog
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation cancelled.')));
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Cancel failed')));
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
                  Text('Reservation', style: theme.textTheme.titleLarge),
                  const Spacer(),
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
    required this.amenityName,
    required this.pin,
    required this.busy,
    required this.onCheckIn,
    required this.onCancel,
  });

  final Reservation reservation;
  final String amenityName;
  final String? pin;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = reservation;
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
        Container(
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
        ),
        const SizedBox(height: 14),
        _Countdown(start: start, end: end, active: active),
        const SizedBox(height: 14),
        if (accessOpen) ...[
          _AccessPanel(qrToken: r.qrToken, pin: pin),
          const SizedBox(height: 14),
          if (r.status == ReservationStatus.booked)
            FilledButton.icon(
              onPressed: (busy || !active) ? null : onCheckIn,
              style:
                  FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.lock_open),
              label: Text(active ? 'Check in' : 'Check in opens at start'),
            ),
        ] else if (liveStatus)
          _LockedAccessCard(pinOpensAt: pinOpensAt),
        const SizedBox(height: 14),
        if (r.isUpcoming)
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
      {required this.start, required this.end, required this.active});
  final DateTime? start;
  final DateTime? end;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    String label;
    String value;
    if (active && end != null) {
      label = 'Time remaining';
      value = _fmt(end!.difference(now));
    } else if (start != null && start!.isAfter(now)) {
      label = 'Starts in';
      value = _fmt(start!.difference(now));
    } else {
      label = 'Status';
      value = 'Ended';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()])),
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
  const _AccessPanel({required this.qrToken, required this.pin});
  final String? qrToken;
  final String? pin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: Column(
        children: [
          Text('YOUR ACCESS',
              style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary)),
          const SizedBox(height: 16),
          if (qrToken != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: QrImageView(data: qrToken!, size: 170),
            ),
          const SizedBox(height: 18),
          Text('PIN',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            pin ?? '••••••',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (pin == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Shown on the device you booked from',
                  style: theme.textTheme.bodySmall),
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
      ReservationStatus.completed => ('Completed', Colors.grey),
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

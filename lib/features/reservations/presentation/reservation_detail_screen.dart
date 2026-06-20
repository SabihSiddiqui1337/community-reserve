import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/router/routes.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../data/reservation_repository.dart';
import '../domain/reservation.dart';

class ReservationDetailScreen extends ConsumerStatefulWidget {
  const ReservationDetailScreen({super.key, required this.reservationId});
  final String reservationId;

  @override
  ConsumerState<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState
    extends ConsumerState<ReservationDetailScreen> {
  Timer? _ticker;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Rebuild every second for the live countdown.
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
        content: Text(ok ? 'Checked in — enjoy!' : 'Access denied: ${res['reason']}'),
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
      builder: (_) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: const Text(
            'Cancelling close to the start time may count as a no-show.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel it')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(reservationRepositoryProvider)
          .cancel(communityId: cid, reservationId: r.id);
      if (mounted) context.go(Routes.myBookings);
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
    final reservation = ref.watch(reservationProvider(widget.reservationId));
    final pinCache = ref.watch(pinCacheProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.myBookings),
        ),
      ),
      body: reservation.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (r) {
          if (r == null) return const Center(child: Text('Not found'));
          final amenity = ref.watch(amenityProvider(r.amenityId)).value;
          final pin = pinCache[r.id];
          return _Body(
            reservation: r,
            amenityName: amenity?.name ?? 'Amenity',
            pin: pin,
            busy: _busy,
            onCheckIn: () => _checkIn(r),
            onCancel: () => _cancel(r),
          );
        },
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
    final active = r.isActiveNow;
    final start = r.startTime;
    final end = r.endTime;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(amenityName,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _StatusChip(status: r.status),
        const SizedBox(height: 8),
        if (start != null)
          Text(DateFormat('EEEE, MMM d · h:mm a').format(start) +
              (end != null ? ' – ${DateFormat('h:mm a').format(end)}' : '')),
        const SizedBox(height: 24),
        _Countdown(start: start, end: end, active: active),
        const SizedBox(height: 24),
        if (active) ...[
          _AccessPanel(qrToken: r.qrToken, pin: pin),
          const SizedBox(height: 16),
          if (r.status == ReservationStatus.booked)
            FilledButton.icon(
              onPressed: busy ? null : onCheckIn,
              icon: const Icon(Icons.login),
              label: const Text('Check in'),
            ),
        ] else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.lock_clock, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                        'Your PIN and QR code unlock when your slot becomes active.'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        if (r.isUpcoming)
          OutlinedButton.icon(
            onPressed: busy ? null : onCancel,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel reservation'),
          ),
      ],
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.start, required this.end, required this.active});
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold)),
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

class _AccessPanel extends StatelessWidget {
  const _AccessPanel({required this.qrToken, required this.pin});
  final String? qrToken;
  final String? pin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Your access', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            if (qrToken != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(data: qrToken!, size: 180),
              ),
            const SizedBox(height: 20),
            Text('PIN', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              pin ?? '••••••',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
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
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      side: BorderSide.none,
    );
  }
}

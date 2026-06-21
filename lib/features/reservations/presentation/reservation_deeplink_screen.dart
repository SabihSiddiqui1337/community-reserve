import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import 'reservation_detail_dialog.dart';

/// Landing screen for a "check in now" notification tap. It opens the
/// reservation detail dialog, then returns the user to My Bookings.
class ReservationDeepLinkScreen extends ConsumerStatefulWidget {
  const ReservationDeepLinkScreen({super.key, required this.reservationId});
  final String reservationId;

  @override
  ConsumerState<ReservationDeepLinkScreen> createState() =>
      _ReservationDeepLinkScreenState();
}

class _ReservationDeepLinkScreenState
    extends ConsumerState<ReservationDeepLinkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showReservationDetailDialog(context, widget.reservationId);
      if (mounted) context.go(Routes.myBookings);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

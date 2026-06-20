import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../community/application/tenant_providers.dart';

/// Admin hub. Phase 1 wires Residency approvals; Phase 6 fills in amenities
/// config, reservations calendar, reports, branding editor and members.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(activeCommunityProvider);
    final items = <_AdminItem>[
      _AdminItem('Residency approvals', Icons.how_to_reg_outlined,
          Routes.adminApprovals),
      _AdminItem('Amenities', Icons.sports_tennis_outlined,
          Routes.adminAmenities),
      _AdminItem('Reservations', Icons.calendar_month_outlined,
          Routes.adminReservations),
      _AdminItem('Reports', Icons.insights_outlined, Routes.adminReports),
      _AdminItem('Branding', Icons.palette_outlined, Routes.adminBranding),
      _AdminItem('Booking rules', Icons.tune, Routes.adminSettings),
      _AdminItem('Members', Icons.groups_outlined, Routes.adminMembers),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(community.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Community administration',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ...items.map((it) => Card(
                child: ListTile(
                  leading: Icon(it.icon),
                  title: Text(it.label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(it.route),
                ),
              )),
        ],
      ),
    );
  }
}

class _AdminItem {
  const _AdminItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

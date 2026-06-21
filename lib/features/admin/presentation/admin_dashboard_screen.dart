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

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(community.name, style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text('Community administration',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              for (final it in items)
                _AdminCard(item: it, onTap: () => context.go(it.route)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.item, required this.onTap});
  final _AdminItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon,
                    color: theme.colorScheme.onPrimary, size: 22),
              ),
              const SizedBox(height: 12),
              Text(item.label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
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

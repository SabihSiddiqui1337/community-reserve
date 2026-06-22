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
    // Reservations & Branding intentionally removed.
    final items = <_AdminItem>[
      _AdminItem('Residency approvals', Icons.how_to_reg_outlined,
          const Color(0xFF22C55E), Routes.adminApprovals),
      _AdminItem('Amenities', Icons.sports_tennis_outlined,
          const Color(0xFF3B82F6), Routes.adminAmenities),
      _AdminItem(
          'Reports', Icons.insights_outlined, const Color(0xFFA855F7),
          Routes.adminReports),
      _AdminItem('Booking rules', Icons.tune, const Color(0xFFF59E0B),
          Routes.adminSettings),
      _AdminItem('Members', Icons.groups_outlined, const Color(0xFF14B8A6),
          Routes.adminMembers),
    ];

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          Text(community.name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text('Community administration',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _AdminRow(
                      item: items[i], onTap: () => context.go(items[i].route)),
                  if (i != items.length - 1)
                    const Divider(height: 1, indent: 68),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminRow extends StatelessWidget {
  const _AdminRow({required this.item, required this.onTap});
  final _AdminItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(item.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _AdminItem {
  const _AdminItem(this.label, this.icon, this.color, this.route);
  final String label;
  final IconData icon;
  final Color color;
  final String route;
}

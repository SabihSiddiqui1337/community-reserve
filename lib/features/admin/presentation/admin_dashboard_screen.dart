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
    final isOwner = ref.watch(isOwnerProvider);
    // Owner-only platform tools form their own block above the per-community
    // admin tools.
    final ownerItems = <_AdminItem>[
      _AdminItem('All Communities', Icons.apartment_outlined,
          const Color(0xFF60A5FA), Routes.adminAllCommunities),
      _AdminItem('Add Community', Icons.add_business_outlined,
          const Color(0xFFC8FA4B), Routes.adminAddCommunity),
    ];
    // Reservations & Branding intentionally removed.
    final adminItems = <_AdminItem>[
      _AdminItem('Residency Approvals', Icons.how_to_reg_outlined,
          const Color(0xFF22C55E), Routes.adminApprovals),
      _AdminItem('Amenities', Icons.sports_tennis_outlined,
          const Color(0xFF3B82F6), Routes.adminAmenities),
      _AdminItem(
          'Reports', Icons.insights_outlined, const Color(0xFFA855F7),
          Routes.adminReports),
      _AdminItem('Booking Rules', Icons.tune, const Color(0xFFF59E0B),
          Routes.adminSettings),
      _AdminItem('Members', Icons.groups_outlined, const Color(0xFF14B8A6),
          Routes.adminMembers),
    ];

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isOwner ? 'Owner' : 'Admin'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.more),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          Text(community.name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
              isOwner
                  ? 'Platform owner — manage every community'
                  : 'Community administration',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          // Owners get a separate "Platform" block above the community tools.
          if (isOwner) ...[
            _SectionLabel('Platform'),
            _AdminCard(items: ownerItems),
            const SizedBox(height: 22),
            _SectionLabel('This community'),
          ],
          _AdminCard(items: adminItems),
        ],
      ),
    );
  }
}

/// A small uppercase section heading above a block of admin rows.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

/// A card grouping a list of admin rows with hairline dividers.
class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.items});
  final List<_AdminItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Builder(
              builder: (context) => _AdminRow(
                  item: items[i], onTap: () => context.go(items[i].route)),
            ),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 68),
          ],
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

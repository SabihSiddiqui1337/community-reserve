import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../community/data/community_directory_repository.dart';
import '../../../community/data/community_repository.dart';
import '../../../community/domain/community.dart';
import '../../../community/domain/community_summary.dart';

/// Owner-only: one community's details, with clear actions to switch into it or
/// edit it (including adding the HOA link). Reached by tapping a row in the
/// "All Communities" list.
class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.communityId});

  final String communityId;

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  Community? _community;
  CommunitySummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await ref.read(communityRepositoryProvider).fetch(widget.communityId);
    final s =
        await ref.read(communityDirectoryRepositoryProvider).fetch(widget.communityId);
    if (!mounted) return;
    setState(() {
      _community = c;
      _summary = s;
      _loading = false;
    });
  }

  void _switch() {
    ref.read(communityOverrideProvider.notifier).select(widget.communityId);
    showSnack(context, 'Switched to ${_community?.name ?? 'community'}');
    context.go(Routes.events);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent =
        ref.watch(currentCommunityIdProvider) == widget.communityId;
    final c = _community;
    final link = (c?.residentPortalUrl ?? '').trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.adminAllCommunities),
        ),
      ),
      body: (_loading || c == null)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c.name,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    if (isCurrent)
                      Chip(
                        label: const Text('Current'),
                        labelStyle: const TextStyle(
                            color: AppTheme.onLime, fontWeight: FontWeight.w700),
                        backgroundColor: AppTheme.lime,
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      children: [
                        _InfoRow(
                            label: 'Address',
                            value: c.address.isNotEmpty ? c.address : '—'),
                        const Divider(height: 1),
                        _InfoRow(
                          label: 'HOA link',
                          value: link.isNotEmpty
                              ? link
                              : 'Not set — tap "Edit details" to add it',
                          valueColor: link.isNotEmpty
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const Divider(height: 1),
                        _InfoRow(
                            label: 'Join code',
                            value: (_summary?.joinCode ?? '').isNotEmpty
                                ? _summary!.joinCode
                                : '—'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isCurrent ? null : _switch,
                    icon: Icon(
                        isCurrent ? Icons.check_circle_outline : Icons.swap_horiz),
                    label: Text(isCurrent
                        ? 'Current community'
                        : 'Switch to this community'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .go(Routes.adminEditCommunityTo(widget.communityId)),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit details'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: valueColor)),
          ),
        ],
      ),
    );
  }
}

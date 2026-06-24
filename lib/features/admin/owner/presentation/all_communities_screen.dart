import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../community/data/community_directory_repository.dart';
import '../../../community/domain/community_summary.dart';

/// Owner-only: every community in the platform. Tapping one switches the active
/// tenant (via [communityOverrideProvider]) so the owner sees its data.
class AllCommunitiesScreen extends ConsumerWidget {
  const AllCommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communities = ref.watch(allCommunitiesProvider);
    final currentId = ref.watch(currentCommunityIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Communities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.admin),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go(Routes.adminAddCommunity),
          ),
        ],
      ),
      body: communities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = list[i];
              return _CommunityTile(
                community: c,
                isCurrent: c.id == currentId,
              );
            },
          );
        },
      ),
    );
  }
}

class _CommunityTile extends ConsumerWidget {
  const _CommunityTile({required this.community, required this.isCurrent});

  final CommunitySummary community;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = community;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.apartment),
        title: Text(c.name),
        subtitle: c.city.isNotEmpty ? Text(c.city) : null,
        // Tapping opens the community's detail page (switch / edit live there).
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrent)
              Chip(
                label: const Text('Current'),
                labelStyle: const TextStyle(
                  color: AppTheme.onLime,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: AppTheme.lime,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.go(Routes.adminCommunityDetailTo(c.id)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apartment_outlined, size: 56, color: AppTheme.muted),
          const SizedBox(height: 16),
          const Text(
            'No communities yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go(Routes.adminAddCommunity),
            child: const Text('Add community'),
          ),
        ],
      ),
    );
  }
}

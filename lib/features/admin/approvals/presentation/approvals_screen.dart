import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../community/application/tenant_providers.dart';
import '../../../community/data/membership_repository.dart';
import '../../../community/domain/membership.dart';
import '../../widgets/member_detail_dialog.dart';

/// Admin residency approvals queue (Phase 1). Lists pending submissions with
/// the uploaded document; tap a row to view full details and approve or reject.
class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cid = ref.watch(currentCommunityIdProvider);
    if (cid == null) {
      return const Scaffold(body: Center(child: Text('No community')));
    }
    final pending = ref.watch(_pendingProvider(cid));

    return Scaffold(
      appBar: AppBar(title: const Text('Residency Approvals')),
      body: pending.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const _Empty();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => _ApprovalTile(membership: list[i]),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
          );
        },
      ),
    );
  }
}

final _pendingProvider =
    StreamProvider.family<List<Membership>, String>((ref, cid) {
  return ref.watch(membershipRepositoryProvider).watchPending(cid);
});

class _ApprovalTile extends ConsumerWidget {
  const _ApprovalTile({required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(memberProfileProvider(membership.userId));

    final name = profile.maybeWhen(
      data: (u) => (u?.name ?? '').isNotEmpty ? u!.name : membership.userId,
      orElse: () => '…',
    );
    final unit =
        membership.unit.isNotEmpty ? 'Unit ${membership.unit}' : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showMemberDetailDialog(
          context,
          ref,
          membership: membership,
          showApproveReject: true,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.titleMedium),
                        if (unit != null)
                          Text(
                            unit,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (membership.verificationDocUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: membership.verificationDocUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, _, _) => const SizedBox(
                      height: 160,
                      child: Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'View Details',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          const Text('No pending approvals'),
        ],
      ),
    );
  }
}

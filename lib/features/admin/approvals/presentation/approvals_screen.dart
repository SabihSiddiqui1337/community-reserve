import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/auth_repository.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../community/data/membership_repository.dart';
import '../../../community/domain/membership.dart';

/// Admin residency approvals queue (Phase 1). Lists pending submissions with
/// the uploaded document; approve or reject (with a reason).
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
      appBar: AppBar(title: const Text('Residency approvals')),
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
            itemBuilder: (context, i) =>
                _ApprovalTile(communityId: cid, membership: list[i]),
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
  const _ApprovalTile({required this.communityId, required this.membership});
  final String communityId;
  final Membership membership;

  Future<void> _approve(WidgetRef ref) async {
    final reviewer = ref.read(currentUidProvider)!;
    await ref
        .read(membershipRepositoryProvider)
        .approve(communityId, membership.userId, reviewer);
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _RejectDialog(),
    );
    if (reason == null) return;
    final reviewer = ref.read(currentUidProvider)!;
    await ref
        .read(membershipRepositoryProvider)
        .reject(communityId, membership.userId, reviewer, reason);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
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
                  child: Text(
                    membership.unit.isNotEmpty
                        ? 'Unit ${membership.unit}'
                        : membership.userId,
                    style: theme.textTheme.titleMedium,
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reject(context, ref),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _approve(ref),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();
  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reason = TextEditingController();
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reason for rejection'),
      content: TextField(
        controller: _reason,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'e.g. document unreadable'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _reason.text.trim()),
          child: const Text('Reject'),
        ),
      ],
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

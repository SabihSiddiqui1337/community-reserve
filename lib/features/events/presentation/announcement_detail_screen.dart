import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../community/application/tenant_providers.dart';
import '../data/announcement_repository.dart';
import '../domain/announcement.dart';

/// Full details for an event / announcement. Opened by tapping a banner on the
/// Events screen. Admins get a Delete action here too.
class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({super.key, required this.announcement});
  final Announcement announcement;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this post?'),
        content: Text('"${announcement.title}" will be removed for everyone.'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Keep'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.error),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    await ref
        .read(announcementRepositoryProvider)
        .delete(cid, announcement.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdmin = ref.watch(isAdminProvider);
    final a = announcement;
    final isEvent = a.type == 'event';
    // Live author name (updates if the author renames), snapshot as fallback.
    final authorName = ref
            .watch(announcementAuthorNameProvider(
                (id: a.authorId, fallback: a.authorName)))
            .value ??
        a.authorName;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEvent ? 'Event' : 'Announcement'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            children: [
              Icon(isEvent ? Icons.event : Icons.campaign,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(isEvent ? 'EVENT' : 'ANNOUNCEMENT',
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          Text(a.title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (a.createdAt != null)
                Text(DateFormat('EEEE, MMMM d · h:mm a').format(a.createdAt!),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 20),
          if (a.body.isNotEmpty)
            Text(a.body,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          if (authorName.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('— $authorName',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic)),
          ],
          if (isAdmin) ...[
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _delete(context, ref),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete post'),
            ),
          ],
        ],
      ),
    );
  }
}

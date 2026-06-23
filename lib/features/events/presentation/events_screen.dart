import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../shared/dialogs/confirm.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../data/announcement_repository.dart';
import '../domain/announcement.dart';
import 'announcement_detail_screen.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(activeCommunityProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final announcements = ref.watch(announcementsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: announcements.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome to',
                                    style: theme.textTheme.bodyMedium),
                                Text(community.name,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          if (isAdmin)
                            IconButton(
                              tooltip: 'Add Event or Announcement',
                              icon: Icon(Icons.add,
                                  color: theme.colorScheme.primary),
                              onPressed: () => _compose(context, ref),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Events & Announcements',
                          style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              if (list.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No announcements yet.')),
                )
              else
                SliverList.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _AnnouncementCard(announcement: list[i])
                        .animate()
                        .fadeIn(delay: (i * 60).ms)
                        .slideY(begin: 0.1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _compose(BuildContext context, WidgetRef ref) async {
    final titleCtl = TextEditingController();
    final bodyCtl = TextEditingController();
    var type = 'announcement';
    final posted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) {
        Future<void> close() async {
          final dirty = titleCtl.text.trim().isNotEmpty ||
              bodyCtl.text.trim().isNotEmpty;
          if (dirty && !await confirmDiscard(context)) return;
          if (context.mounted) Navigator.pop(context, false);
        }

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 18),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('New Post',
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        IconButton(
                            icon: const Icon(Icons.close), onPressed: close),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Announcement'),
                          selected: type == 'announcement',
                          onSelected: (_) =>
                              setState(() => type = 'announcement'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Event'),
                          selected: type == 'event',
                          onSelected: (_) => setState(() => type = 'event'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyCtl,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Post'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (posted != true) return;
    final cid = ref.read(currentCommunityIdProvider);
    final user = ref.read(currentUserProvider).value;
    final author = user?.name ?? 'Admin';
    if (cid == null || titleCtl.text.trim().isEmpty) return;
    await ref.read(announcementRepositoryProvider).post(
          cid,
          Announcement(
            id: '',
            title: titleCtl.text.trim(),
            body: bodyCtl.text.trim(),
            authorName: author,
            authorId: user?.uid ?? '',
            type: type,
          ),
        );
  }
}

/// The author's CURRENT name (live from their profile), so renames propagate to
/// every post they made. Falls back to the snapshot while loading / for legacy.
String _authorName(WidgetRef ref, Announcement a) =>
    ref
        .watch(announcementAuthorNameProvider(
            (id: a.authorId, fallback: a.authorName)))
        .value ??
    a.authorName;

class _AnnouncementCard extends ConsumerWidget {
  const _AnnouncementCard({required this.announcement});
  final Announcement announcement;

  void _open(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => AnnouncementDetailScreen(announcement: announcement),
    ));
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdmin = ref.watch(isAdminProvider);
    final a = announcement;
    final isEvent = a.type == 'event';
    final isLong = a.body.length > 120;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _open(context),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isEvent ? Icons.event : Icons.campaign,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(a.title,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    if (a.createdAt != null)
                      Text(DateFormat('MMM d').format(a.createdAt!),
                          style: theme.textTheme.bodySmall),
                  ],
                ),
                if (a.body.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    a.body,
                    style: theme.textTheme.bodyMedium,
                    maxLines: isLong ? 3 : null,
                    overflow: isLong ? TextOverflow.ellipsis : null,
                  ),
                  if (isLong)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('more…',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
                if (_authorName(ref, a).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('— ${_authorName(ref, a)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (!isAdmin) return card;

    // Admins: swipe left to reveal a delete action; tapping it asks to confirm
    // (no dialog appears until the delete button is pressed).
    return Slidable(
      key: ValueKey('ann_${a.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) async {
              if (!await _confirmDelete(context)) return;
              final cid = ref.read(currentCommunityIdProvider);
              if (cid != null) {
                await ref
                    .read(announcementRepositoryProvider)
                    .delete(cid, a.id);
              }
            },
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
      child: card,
    );
  }
}

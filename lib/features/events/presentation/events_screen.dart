import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/branded_background.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../data/announcement_repository.dart';
import '../domain/announcement.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(activeCommunityProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final announcements = ref.watch(announcementsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _compose(context, ref),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Post'),
            )
          : null,
      body: BrandedBackground(
        child: SafeArea(
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
                        Text('Welcome to', style: theme.textTheme.bodyMedium),
                        Text(community.name,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text('Events & announcements',
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
      ),
    );
  }

  Future<void> _compose(BuildContext context, WidgetRef ref) async {
    final titleCtl = TextEditingController();
    final bodyCtl = TextEditingController();
    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New announcement',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
    if (posted != true) return;
    final cid = ref.read(currentCommunityIdProvider);
    final author = ref.read(currentUserProvider).value?.name ?? 'Admin';
    if (cid == null || titleCtl.text.trim().isEmpty) return;
    await ref.read(announcementRepositoryProvider).post(
          cid,
          Announcement(
            id: '',
            title: titleCtl.text.trim(),
            body: bodyCtl.text.trim(),
            authorName: author,
          ),
        );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});
  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = announcement;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign, color: theme.colorScheme.primary, size: 20),
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
              Text(a.body, style: theme.textTheme.bodyMedium),
            ],
            if (a.authorName.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('— ${a.authorName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

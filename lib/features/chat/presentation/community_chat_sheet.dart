import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_snack.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../data/chat_providers.dart';
import '../data/chat_repository.dart';
import '../domain/chat_channel.dart';
import '../domain/dm_thread.dart';
import 'chat_avatar.dart';
import 'chat_message_view.dart';
import 'member_picker_sheet.dart';

/// Opens the full-height Community Chat modal (Channels + DMs tabs).
///
/// This is the feature's public API — call it from the app shell.
Future<void> showCommunityChat(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierColor: Colors.black54,
    builder: (_) => const Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: _CommunityChatModal(),
    ),
  );
}

class _CommunityChatModal extends StatelessWidget {
  const _CommunityChatModal();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: const _ChatHome(),
        ),
      ),
    );
  }
}

/// Tabbed home: a "Community Chat" header with an X, Channels + DMs tabs.
class _ChatHome extends ConsumerStatefulWidget {
  const _ChatHome();

  @override
  ConsumerState<_ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends ConsumerState<_ChatHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Text('Community Chat',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _ChannelsTab(),
                _DmsTab(),
              ],
            ),
          ),
        ],
      ),
      // Bottom tab bar (Channels / DMs) — anchored to the bottom edge.
      bottomNavigationBar: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        child: SafeArea(
          top: false,
          child: TabBar(
            controller: _tabs,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Channels'),
              Tab(icon: Icon(Icons.people_outline), text: 'DMs'),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Channels tab
// ---------------------------------------------------------------------------

class _ChannelsTab extends ConsumerWidget {
  const _ChannelsTab();

  Future<void> _newChannel(BuildContext context, WidgetRef ref) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    final name = await _promptChannelName(context);
    if (name == null || name.trim().isEmpty) return;
    final channel = await ref
        .read(chatRepositoryProvider)
        .createChannel(cid, name.trim());
    if (context.mounted) _openChannel(context, channel);
  }

  void _openChannel(BuildContext context, ChatChannel channel) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ChannelMessagePage(channel: channel),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final channelsAsync = ref.watch(channelsProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return channelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (channels) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (isAdmin)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(Icons.add, color: theme.colorScheme.primary),
              ),
              title: Text('New channel',
                  style: TextStyle(color: theme.colorScheme.primary)),
              onTap: () => _newChannel(context, ref),
            ),
          if (channels.isEmpty && !isAdmin)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('No channels yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ),
            ),
          for (final c in channels)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text('#',
                    style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700)),
              ),
              title: Text(c.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: c.isGeneral ? const Text('General channel') : null,
              onTap: () => _openChannel(context, c),
            ),
        ],
      ),
    );
  }
}

class _ChannelMessagePage extends ConsumerWidget {
  const _ChannelMessagePage({required this.channel});
  final ChatChannel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      body: SafeArea(
        child: ChatMessageView(
          target: ChatTarget.channel(channel.id),
          titlePrefix: '# ',
          title: channel.name,
          inputHint: 'Chat in #${channel.name}',
          onBack: () => Navigator.of(context).pop(),
          trailing: IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettings(context, ref),
          ),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.read(isAdminProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.tag),
                title: Text('#${channel.name}'),
                subtitle: Text(
                  channel.isGeneral ? 'General channel' : 'Channel settings',
                ),
              ),
              if (isAdmin) ...[
                const Divider(height: 1),
                if (channel.isGeneral)
                  ListTile(
                    enabled: false,
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete channel'),
                    subtitle:
                        const Text("The General channel can't be deleted."),
                  )
                else
                  ListTile(
                    leading: Icon(Icons.delete_outline,
                        color: theme.colorScheme.error),
                    title: Text('Delete channel',
                        style: TextStyle(color: theme.colorScheme.error)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _confirmDelete(context, ref);
                    },
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    final required = 'DELETE ${channel.name.toUpperCase()}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteChannelDialog(requiredText: required),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(chatRepositoryProvider).deleteChannel(cid, channel.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    showSnack(context, 'Channel deleted');
  }
}

/// Type-to-confirm dialog: the Delete button stays disabled until the typed
/// text exactly matches `requiredText` (case-sensitive).
class _DeleteChannelDialog extends StatefulWidget {
  const _DeleteChannelDialog({required this.requiredText});
  final String requiredText;

  @override
  State<_DeleteChannelDialog> createState() => _DeleteChannelDialogState();
}

class _DeleteChannelDialogState extends State<_DeleteChannelDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = _controller.text == widget.requiredText;
    return AlertDialog(
      title: const Text('Delete channel'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type ${widget.requiredText} to confirm.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(hintText: widget.requiredText),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: matches ? () => Navigator.pop(context, true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

Future<String?> _promptChannelName(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New channel'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Channel name'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// DMs tab
// ---------------------------------------------------------------------------

class _DmsTab extends ConsumerWidget {
  const _DmsTab();

  Future<void> _startConversation(BuildContext context, WidgetRef ref) async {
    final cid = ref.read(currentCommunityIdProvider);
    final me = ref.read(currentUidProvider);
    if (cid == null || me == null) return;
    final chosen = await showMemberPicker(context);
    if (chosen == null || chosen.isEmpty || !context.mounted) return;

    final myName = ref.read(currentUserProvider).value?.name.trim();
    final ids = [me, ...chosen.map((m) => m.uid)];
    final names = [
      (myName == null || myName.isEmpty) ? 'You' : myName,
      ...chosen.map((m) => m.name),
    ];
    final thread = await ref.read(chatRepositoryProvider).findOrCreateThread(
          cid,
          participantIds: ids,
          participantNames: names,
        );
    if (context.mounted) _openThread(context, ref, thread);
  }

  void _openThread(BuildContext context, WidgetRef ref, DmThread thread) {
    final me = ref.read(currentUidProvider) ?? '';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _DmMessagePage(thread: thread, me: me),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final me = ref.watch(currentUidProvider) ?? '';
    final threadsAsync = ref.watch(dmThreadsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
          child: Row(
            children: [
              Text('DMs',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                color: theme.colorScheme.primary,
                onPressed: () => _startConversation(context, ref),
              ),
            ],
          ),
        ),
        Expanded(
          child: threadsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (threads) {
              if (threads.isEmpty) {
                return Center(
                  child: Text('No conversations yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                );
              }
              return ListView.builder(
                itemCount: threads.length,
                itemBuilder: (context, i) {
                  final t = threads[i];
                  final title = t.title(me);
                  return ListTile(
                    leading: ChatAvatar(
                      label: title,
                      groupCount: t.isGroup ? t.participantIds.length : null,
                    ),
                    title: Text(title.isEmpty ? 'Conversation' : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: t.lastText.isEmpty
                        ? null
                        : Text(t.lastText,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      _previewDate(t.lastAt ?? t.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    onTap: () => _openThread(context, ref, t),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _previewDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) {
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ap = dt.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $ap';
    }
    return '${dt.month}/${dt.day}/${dt.year % 100}';
  }
}

class _DmMessagePage extends StatelessWidget {
  const _DmMessagePage({required this.thread, required this.me});
  final DmThread thread;
  final String me;

  @override
  Widget build(BuildContext context) {
    final title = thread.title(me);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      body: SafeArea(
        child: ChatMessageView(
          target: ChatTarget.dm(thread.id),
          title: title.isEmpty ? 'Conversation' : title,
          inputHint: 'Message',
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

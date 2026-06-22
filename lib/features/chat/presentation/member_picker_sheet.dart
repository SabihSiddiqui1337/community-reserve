import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../data/chat_providers.dart';
import 'chat_avatar.dart';

/// Multi-select member picker for starting a 1:1 or group DM. Returns the
/// chosen members (excluding the current user), or null if dismissed.
Future<List<ChatMember>?> showMemberPicker(BuildContext context) {
  return showModalBottomSheet<List<ChatMember>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _MemberPickerSheet(),
  );
}

class _MemberPickerSheet extends ConsumerStatefulWidget {
  const _MemberPickerSheet();

  @override
  ConsumerState<_MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends ConsumerState<_MemberPickerSheet> {
  final _search = TextEditingController();
  final _selected = <String>{};
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final me = ref.watch(currentUidProvider);
    final membersAsync = ref.watch(chatMembersProvider);

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return membersAsync.when(
            loading: () => const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 240,
              child: Center(child: Text('Error: $e')),
            ),
            data: (members) {
              final candidates = members
                  .where((m) => m.uid != me)
                  .where((m) => _query.isEmpty ||
                      m.name.toLowerCase().contains(_query) ||
                      m.unit.toLowerCase().contains(_query))
                  .toList();
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Text('New conversation',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _search,
                      onChanged: (v) =>
                          setState(() => _query = v.trim().toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: 'Search members',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: candidates.isEmpty
                        ? Center(
                            child: Text('No members found',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant)),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: candidates.length,
                            itemBuilder: (context, i) {
                              final m = candidates[i];
                              final checked = _selected.contains(m.uid);
                              return CheckboxListTile(
                                value: checked,
                                onChanged: (v) => setState(() {
                                  if (v ?? false) {
                                    _selected.add(m.uid);
                                  } else {
                                    _selected.remove(m.uid);
                                  }
                                }),
                                secondary: ChatAvatar(label: m.name, radius: 20),
                                title: Text(m.name),
                                subtitle: m.unit.isEmpty
                                    ? null
                                    : Text('Unit ${m.unit}'),
                                activeColor: theme.colorScheme.primary,
                                checkColor: theme.colorScheme.onPrimary,
                              );
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: FilledButton(
                        onPressed: _selected.isEmpty
                            ? null
                            : () {
                                final chosen = members
                                    .where((m) => _selected.contains(m.uid))
                                    .toList();
                                Navigator.pop(context, chosen);
                              },
                        child: Text(_selected.length <= 1
                            ? 'Start chat'
                            : 'Start group (${_selected.length})'),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

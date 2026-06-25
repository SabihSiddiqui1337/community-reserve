import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/format/contact.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../community/domain/membership.dart';
import '../../widgets/member_detail_dialog.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(allMembershipsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.admin),
        ),
      ),
      body: members.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _MemberTile(membership: list[i]),
        ),
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final m = membership;
    final profile = ref.watch(memberProfileProvider(m.userId));
    final name = profile.maybeWhen(
      data: (u) => (u?.name ?? '').isNotEmpty
          ? u!.name
          : ((u?.email ?? '').isNotEmpty ? u!.email : 'Member'),
      orElse: () => '…',
    );
    return Card(
      child: ListTile(
        onTap: () => showMemberDetailDialog(
          context,
          ref,
          membership: m,
          showRemove: !m.isAdmin,
        ),
        leading: CircleAvatar(
          backgroundColor: m.isAdmin
              ? theme.colorScheme.tertiaryContainer
              : theme.colorScheme.primaryContainer,
          child: Icon(m.isAdmin ? Icons.shield_outlined : Icons.person_outline),
        ),
        title: Text(name),
        subtitle: Text('${titleCase(m.role.name)} · '
            '${titleCase(m.residencyStatus.name)}'
            '${m.isBanned ? ' · Banned' : ''}'),
        trailing: Text(
          'View Details',
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

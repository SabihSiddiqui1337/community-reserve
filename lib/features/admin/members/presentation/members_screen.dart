import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../community/domain/membership.dart';

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

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = membership;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: m.isAdmin
              ? theme.colorScheme.tertiaryContainer
              : theme.colorScheme.primaryContainer,
          child: Icon(m.isAdmin ? Icons.shield_outlined : Icons.person_outline),
        ),
        title: Text(m.unit.isNotEmpty ? 'Unit ${m.unit}' : m.userId),
        subtitle: Text(
            '${m.role.name} · ${m.residencyStatus.name} · ${m.noShowCount} no-shows'),
        trailing: m.isBanned
            ? const Chip(label: Text('Banned'))
            : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/format/contact.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/domain/membership.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final membership = ref.watch(currentMembershipProvider);
    final community = ref.watch(activeCommunityProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(Routes.editProfile),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              children: [
                Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: (user?.photoUrl ?? '').isNotEmpty
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: (user?.photoUrl ?? '').isEmpty
                      ? Text(
                          (user?.name.isNotEmpty ?? false)
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.headlineMedium,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? 'Resident',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(user?.email ?? '',
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _Section(title: 'Community', children: [
            _Row(label: 'Community', value: community.name),
            _Row(
                label: 'Address',
                value: addressTwoLine((membership?.address.isNotEmpty ?? false)
                    ? membership!.address
                    : community.address)),
            _Row(
                label: 'Unit',
                value: membership?.unit.isNotEmpty == true
                    ? membership!.unit
                    : '—'),
            _Row(
                label: 'Residency',
                value: _residencyLabel(membership?.residencyStatus)),
          ]),
          const SizedBox(height: 16),
          // Admin entry point — only for admins/directors. Styled identically
          // to the Account row (same card, font color, chevron).
          if (isAdmin) ...[
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Admin',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(Routes.admin),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Account',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.account),
            ),
          ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: FilledButton.icon(
              // Red — it's a destructive action (signing out).
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD33A3F),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _confirmSignOut(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to sign out?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD33A3F),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  String _residencyLabel(ResidencyStatus? s) => switch (s) {
        ResidencyStatus.verified => 'Verified',
        ResidencyStatus.pending => 'Pending',
        ResidencyStatus.rejected => 'Rejected',
        null => '—',
      };
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 4),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

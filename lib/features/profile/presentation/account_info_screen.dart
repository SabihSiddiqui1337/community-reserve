import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/domain/membership.dart';

/// Formats a 10-digit US phone as `(xxx) - xxx xxxx`; returns the raw value
/// unchanged if it isn't 10 digits.
String formatPhone(String raw) {
  final d = raw.replaceAll(RegExp(r'\D'), '');
  if (d.length != 10) return raw;
  return '(${d.substring(0, 3)}) - ${d.substring(3, 6)} ${d.substring(6)}';
}

/// Personal details + community standing. Reached from Account → Account
/// Information; the Edit action opens the profile editor.
class AccountInfoScreen extends ConsumerWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final membership = ref.watch(currentMembershipProvider);
    final community = ref.watch(activeCommunityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.push(Routes.editProfile),
            child: const Text('Edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _Section(title: 'Profile', children: [
            _Row(label: 'Name', value: user?.name.isNotEmpty == true
                ? user!.name
                : '—'),
            _Row(label: 'Email', value: user?.email ?? '—'),
            _Row(
                label: 'Phone',
                value: user?.phone.isNotEmpty == true
                    ? formatPhone(user!.phone)
                    : '—'),
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Community', children: [
            _Row(label: 'Community', value: community.name),
            _Row(
                label: 'Address',
                value: (membership?.address.isNotEmpty ?? false)
                    ? membership!.address
                    : community.address),
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
          _Section(title: 'Standing', children: [
            _Row(
                label: 'No-shows',
                value: '${membership?.noShowCount ?? 0}'),
            _Row(
                label: 'Status',
                value: (membership?.isBanned ?? false)
                    ? 'Temporarily paused'
                    : 'Good standing'),
          ]),
        ],
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/domain/membership.dart';
import '../../payments/presentation/payment_methods_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final membership = ref.watch(currentMembershipProvider);
    final community = ref.watch(activeCommunityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (user?.name.isNotEmpty ?? false)
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.headlineMedium,
                  ),
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
          const SizedBox(height: 16),
          _Section(title: 'Payment methods', children: [
            if ((user?.paymentMethods ?? const []).isEmpty)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.credit_card),
                title: Text('No cards on file'),
              )
            else
              for (final c in user!.paymentMethods)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.credit_card),
                  title: Text('${c.brand}  •••• ${c.last4}'),
                  trailing: c.id == user.selectedCardId
                      ? Icon(Icons.check_circle,
                          color: theme.colorScheme.primary)
                      : null,
                ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tune),
              title: const Text('Manage cards'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const PaymentMethodsSheet(),
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.apple),
              title: Text('Apple Pay'),
              subtitle: Text('Available at checkout'),
            ),
          ]),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
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

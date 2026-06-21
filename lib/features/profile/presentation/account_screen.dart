import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/domain/app_user.dart';

/// Account hub (reached from Profile). Groups personal details and payment
/// methods under one place, matching the reference Account screen.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final card = user?.selectedCard;
    final paymentSubtitle = card != null ? '•••• ${card.last4}' : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Account'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _AccountTile(
            icon: Icons.person_outline,
            title: 'Account Information',
            onTap: () => context.push(Routes.accountInfo),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _AccountTile(
            icon: Icons.credit_card,
            title: 'Payment Info',
            subtitle: paymentSubtitle,
            onTap: () => context.push(Routes.paymentInfo),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon),
      title: Text(title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

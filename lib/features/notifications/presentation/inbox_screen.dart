import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../community/application/tenant_providers.dart';
import '../data/notification_repository.dart';
import '../domain/app_notification.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go(Routes.home),
        ),
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _NotificationTile(notification: list[i]),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final n = notification;
    return Card(
      color: n.read ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: ListTile(
        leading: Icon(_iconFor(n.type), color: theme.colorScheme.primary),
        title: Text(n.title,
            style: TextStyle(
                fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
        subtitle: Text(n.body),
        trailing: n.createdAt == null
            ? null
            : Text(DateFormat('MMM d').format(n.createdAt!),
                style: theme.textTheme.bodySmall),
        onTap: () {
          final cid = ref.read(currentCommunityIdProvider);
          if (cid != null && !n.read) {
            ref.read(notificationRepositoryProvider).markRead(cid, n.id);
          }
        },
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        'waitlist' => Icons.event_available,
        'reminder' => Icons.alarm,
        'ban' => Icons.block,
        _ => Icons.notifications_outlined,
      };
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../community/application/tenant_providers.dart';
import '../data/notification_repository.dart';
import '../domain/app_notification.dart';

/// In-app notification inbox. Tapping a notification marks it read and, when it
/// carries a deep-link [AppNotification.route], navigates there (e.g. a
/// waitlist "slot opened" notification opens Book a Court for that sport).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(myNotificationsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: items.isEmpty
          ? Center(
              child: Text('No notifications yet.',
                  style: theme.textTheme.bodyMedium),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) =>
                  _NotificationTile(notification: items[i]),
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
    final created = n.createdAt;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: n.type == 'waitlist'
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          n.type == 'waitlist'
              ? Icons.notifications_active
              : Icons.notifications_none,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(n.title,
          style: TextStyle(
              fontWeight: n.read ? FontWeight.w500 : FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(n.body),
          if (created != null) ...[
            const SizedBox(height: 4),
            Text(DateFormat('EEE, MMM d · h:mm a').format(created),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
      trailing: n.read
          ? null
          : Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () {
        final cid = ref.read(currentCommunityIdProvider);
        if (cid != null && !n.read) {
          ref.read(notificationRepositoryProvider).markRead(cid, n.id);
        }
        final route = n.route;
        if (route != null && route.isNotEmpty) {
          context.go(route);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../amenities/data/amenity_repository.dart';
import '../data/waitlist_repository.dart';
import '../domain/waitlist_entry.dart';

class WaitlistScreen extends ConsumerWidget {
  const WaitlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(myWaitlistProvider);
    final amenities = ref.watch(amenitiesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My waitlist'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go(Routes.home),
        ),
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
                child: Text('You\'re not on any waitlists right now.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final w = list[i];
              final name = amenities
                      .where((a) => a.id == w.amenityId)
                      .firstOrNull
                      ?.name ??
                  'Amenity';
              return _WaitlistTile(entry: w, amenityName: name);
            },
          );
        },
      ),
    );
  }
}

class _WaitlistTile extends StatelessWidget {
  const _WaitlistTile({required this.entry, required this.amenityName});
  final WaitlistEntry entry;
  final String amenityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (entry.status) {
      WaitlistStatus.waiting => ('Waiting', Colors.orange),
      WaitlistStatus.notified => ('Slot open!', Colors.green),
      WaitlistStatus.fulfilled => ('Fulfilled', Colors.blue),
      WaitlistStatus.expired => ('Expired', Colors.grey),
    };
    return Card(
      child: ListTile(
        leading: Icon(Icons.hourglass_bottom, color: theme.colorScheme.primary),
        title: Text(amenityName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(entry.desiredStart == null
            ? ''
            : DateFormat('EEE, MMM d · h:mm a').format(entry.desiredStart!)),
        trailing: Chip(
          label: Text(label),
          backgroundColor: color.withValues(alpha: 0.15),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

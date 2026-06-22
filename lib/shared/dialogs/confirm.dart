import 'package:flutter/material.dart';

/// Asks the user to confirm discarding unsaved edits. Returns true to discard.
/// Used by add/edit forms so closing (via the X) never silently loses input.
Future<bool> confirmDiscard(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Discard changes?'),
      content: const Text("You haven't saved yet. Close without saving?"),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep editing'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return ok ?? false;
}

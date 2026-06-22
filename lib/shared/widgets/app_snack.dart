import 'package:flutter/material.dart';

/// Shows a SnackBar that REPLACES any currently-visible one, so rapidly
/// repeated triggers (e.g. tapping the same action 5×) don't queue up a stack
/// of identical toasts. Use this everywhere instead of calling
/// `ScaffoldMessenger.of(context).showSnackBar(...)` directly.
void showSnack(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
}

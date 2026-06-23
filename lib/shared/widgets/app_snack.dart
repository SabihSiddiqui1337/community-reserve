import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// A dedicated overlay that sits ABOVE the router (wired in `app.dart`'s
/// builder), so toasts render on top of everything — even during a route
/// transition triggered right after `showSnack` (e.g. "Request sent" → navigate).
final GlobalKey<OverlayState> toastOverlayKey = GlobalKey<OverlayState>();

/// A single app toast that REPLACES any visible one (no stacking).
/// - **Success/info** → slides in from the TOP, dark with a lime accent.
/// - **Errors** (`isError: true`) → anchored at the BOTTOM, RED, with an error
///   icon — for "exceeds the weekly limit" and similar failures.
OverlayEntry? _current;

void showSnack(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  bool isError = false,
}) {
  final overlay = toastOverlayKey.currentState ??
      Navigator.of(context, rootNavigator: true).overlay ??
      Overlay.maybeOf(context);
  if (overlay == null) return;

  _current?.remove();
  _current = null;

  late final OverlayEntry entry;
  void dismiss() {
    if (_current == entry) {
      entry.remove();
      _current = null;
    }
  }

  entry = OverlayEntry(
    builder: (_) =>
        _AppToast(message: message, isError: isError, onDismiss: dismiss),
  );
  _current = entry;
  overlay.insert(entry);
  Future.delayed(duration, dismiss);
}

/// Convenience for error toasts.
void showError(BuildContext context, String message,
        {Duration duration = const Duration(seconds: 4)}) =>
    showSnack(context, message, duration: duration, isError: true);

class _AppToast extends StatefulWidget {
  const _AppToast(
      {required this.message, required this.isError, required this.onDismiss});
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    final isError = widget.isError;

    final bg = isError ? const Color(0xFFD33A3F) : const Color(0xFF1C1F26);
    final border =
        isError ? Colors.white.withValues(alpha: 0.35) : AppTheme.lime;
    final icon = isError ? Icons.error_outline : Icons.check_circle;
    final iconColor = isError ? Colors.white : AppTheme.lime;

    final card = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x80000000),
                      blurRadius: 20,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.message,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Errors anchor to the bottom (above the floating nav); others to the top.
    final slideBegin =
        isError ? const Offset(0, 0.5) : const Offset(0, -0.5);
    final animated = FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: slideBegin, end: Offset.zero)
            .animate(curved),
        child: card,
      ),
    );

    return Positioned(
      left: 14,
      right: 14,
      top: isError ? null : mq.padding.top + 10,
      // Lift error toasts clear of the floating nav + any bottom action bar
      // (e.g. the Book "Check out" total banner) so they sit ABOVE it.
      bottom: isError ? mq.padding.bottom + 160 : null,
      child: animated,
    );
  }
}

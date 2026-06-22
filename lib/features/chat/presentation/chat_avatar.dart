import 'package:flutter/material.dart';

/// Deterministic avatar color from a name (stable across rebuilds/users).
Color avatarColor(String seed) {
  const palette = [
    Color(0xFF7C5CFF),
    Color(0xFF2DB6A3),
    Color(0xFFE0729B),
    Color(0xFFE0A33C),
    Color(0xFF4C8DF6),
    Color(0xFFD96B5C),
    Color(0xFF5CB85C),
    Color(0xFFB05CD9),
  ];
  var hash = 0;
  for (final code in seed.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}

String _initial(String name) {
  final t = name.trim();
  return t.isEmpty ? '?' : t.characters.first.toUpperCase();
}

/// Circle avatar showing an initial, or a participant count for groups.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    super.key,
    required this.label,
    this.groupCount,
    this.radius = 22,
  });

  /// Name used for color + initial (ignored when [groupCount] is set).
  final String label;

  /// When non-null and >= 3, shows the number instead of an initial.
  final int? groupCount;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isGroup = groupCount != null && groupCount! >= 3;
    final seed = isGroup ? 'group-$groupCount-$label' : label;
    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor(seed),
      child: Text(
        isGroup ? '$groupCount' : _initial(label),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}

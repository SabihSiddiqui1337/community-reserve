import 'package:flutter/material.dart';

/// Hex (`#RRGGBB` or `#AARRGGBB`) → [Color]. Tolerant of a missing `#`.
/// Falls back to [fallback] on any malformed input so a bad branding value
/// can never crash the theme.
Color hexToColor(String hex, {Color fallback = const Color(0xFF5B8DEF)}) {
  var value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return fallback;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

import 'package:flutter/services.dart';

/// Formats a US phone number as `(123) 456-7890`. Handles partial input too,
/// so it works both for live typing and for displaying a stored value.
String formatPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final t = digits.length > 10 ? digits.substring(0, 10) : digits;
  if (t.isEmpty) return '';
  if (t.length < 4) return '($t';
  if (t.length < 7) return '(${t.substring(0, 3)}) ${t.substring(3)}';
  return '(${t.substring(0, 3)}) ${t.substring(3, 6)}-${t.substring(6)}';
}

/// Live formatter for a phone TextField — formats to `(123) 456-7890` as the
/// user types and keeps the caret at the end.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatPhone(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Splits a one-line address into two display lines at the first comma:
/// "10810 Roller Mill Ln, Sugar Land TX 77498" →
///   line 1: "10810 Roller Mill Ln"
///   line 2: "Sugar Land TX 77498"
String addressTwoLine(String addr) {
  final i = addr.indexOf(',');
  if (i < 0) return addr.trim();
  final street = addr.substring(0, i).trim();
  final rest = addr.substring(i + 1).trim();
  return rest.isEmpty ? street : '$street\n$rest';
}

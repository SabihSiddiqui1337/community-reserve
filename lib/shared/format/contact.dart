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

/// Capitalizes the first letter of every word, leaving the rest as-is:
/// "sugar land" → "Sugar Land".
String titleCase(String s) =>
    s.replaceAllMapped(RegExp(r'\b\w'), (m) => m.group(0)!.toUpperCase());

/// Live formatter that title-cases as the user types (e.g. city field).
class TitleCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: titleCase(newValue.text),
      selection: newValue.selection,
    );
  }
}

/// Formats a stored "line1, city, state zip" address for display: street on the
/// first line, "City, State" on the second (city title-cased), and the ZIP on
/// its own line. Falls back gracefully for partial / non-standard addresses.
String formatAddress(String addr) {
  final parts =
      addr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return addr.trim();
  if (parts.length == 1) return parts[0];

  final street = parts[0];
  final city = titleCase(parts[1]);
  final stateZip = parts.sublist(2).join(', ').trim();

  final m = RegExp(r'^(.*?)\s+(\d{5}(?:-\d{4})?)$').firstMatch(stateZip);
  if (m != null) {
    final state = m.group(1)!.trim();
    final cityState = state.isNotEmpty ? '$city, $state' : city;
    return '$street\n$cityState\n${m.group(2)}';
  }
  final cityLine = stateZip.isNotEmpty ? '$city, $stateZip' : city;
  return '$street\n$cityLine';
}

/// Splits a one-line address into two display lines at the first comma.
String addressTwoLine(String addr) {
  final i = addr.indexOf(',');
  if (i < 0) return addr.trim();
  final street = addr.substring(0, i).trim();
  final rest = addr.substring(i + 1).trim();
  return rest.isEmpty ? street : '$street\n$rest';
}

import 'dart:convert';

import 'package:http/http.dart' as http;

/// A single address suggestion returned from the Photon geocoder, flattened
/// into the fields the residency form needs.
class AddressSuggestion {
  AddressSuggestion({
    required this.label,
    required this.line1,
    required this.city,
    required this.state,
    required this.zip,
  });

  final String label;
  final String line1;
  final String city;
  final String state;
  final String zip;
}

/// Fetches address suggestions from Photon (OpenStreetMap). Free, no API key,
/// CORS-enabled. Never throws — returns an empty list on any error.
Future<List<AddressSuggestion>> fetchAddressSuggestions(String query) async {
  final q = query.trim();
  if (q.isEmpty) return [];
  try {
    final uri = Uri.parse(
      'https://photon.komoot.io/api/'
      '?q=${Uri.encodeQueryComponent(q)}&limit=6&lang=en',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];

    final decoded = json.decode(res.body) as Map<String, dynamic>;
    final features = (decoded['features'] as List?) ?? const [];

    final all = <Map<String, dynamic>>[
      for (final f in features)
        if (f is Map<String, dynamic> &&
            f['properties'] is Map<String, dynamic>)
          f['properties'] as Map<String, dynamic>,
    ];

    // Prefer US results; if none are US, keep everything.
    final us = all
        .where((p) =>
            (p['countrycode'] as String?)?.toLowerCase() == 'us')
        .toList();
    final props = us.isNotEmpty ? us : all;

    final suggestions = <AddressSuggestion>[];
    for (final p in props) {
      final s = _toSuggestion(p);
      if (s.label.isNotEmpty) suggestions.add(s);
    }
    return suggestions;
  } catch (_) {
    return [];
  }
}

String _str(Object? v) => (v is String) ? v.trim() : '';

AddressSuggestion _toSuggestion(Map<String, dynamic> p) {
  final houseNumber = _str(p['housenumber']);
  final street = _str(p['street']);
  var line1 = [houseNumber, street].where((s) => s.isNotEmpty).join(' ').trim();
  if (line1.isEmpty) line1 = _str(p['name']);

  var city = _str(p['city']);
  if (city.isEmpty) city = _str(p['district']);
  if (city.isEmpty) city = _str(p['county']);

  final state = _str(p['state']);
  final zip = _str(p['postcode']);

  final label = [
    line1,
    city,
    '$state $zip'.trim(),
  ].where((s) => s.isNotEmpty).join(', ');

  return AddressSuggestion(
    label: label,
    line1: line1,
    city: city,
    state: state,
    zip: zip,
  );
}

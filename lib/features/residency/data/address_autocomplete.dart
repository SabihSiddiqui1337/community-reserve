import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

/// A single address suggestion from the Google Places API (New). Holds just the
/// place id (to fetch details) and a human-readable label for the dropdown.
class AddressSuggestion {
  final String placeId;
  final String label;
  const AddressSuggestion({required this.placeId, required this.label});
}

String get _apiKey => Firebase.app().options.apiKey;

/// Fetches US address suggestions from the Google Places API (New) Autocomplete
/// endpoint. Never throws — returns an empty list on any error or non-200.
Future<List<AddressSuggestion>> fetchAddressSuggestions(String query) async {
  final q = query.trim();
  if (q.isEmpty) return [];
  try {
    final res = await http.post(
      Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
      },
      body: json.encode({
        'input': q,
        'includedRegionCodes': ['us'],
      }),
    );
    if (res.statusCode != 200) return [];

    final decoded = json.decode(res.body) as Map<String, dynamic>;
    final suggestions = (decoded['suggestions'] as List?) ?? const [];

    final out = <AddressSuggestion>[];
    for (final s in suggestions) {
      if (s is! Map<String, dynamic>) continue;
      final pp = s['placePrediction'];
      if (pp is! Map<String, dynamic>) continue;
      final placeId = (pp['placeId'] as String?) ?? '';
      final label = ((pp['text'] as Map<String, dynamic>?)?['text'] as String?)
              ?.trim() ??
          '';
      if (label.isEmpty) continue;
      out.add(AddressSuggestion(placeId: placeId, label: label));
      if (out.length >= 6) break;
    }
    return out;
  } catch (_) {
    return [];
  }
}

/// Fetches the structured address components for a place id from the Google
/// Places API (New) Place Details endpoint. Returns null on any error/non-200.
Future<({String line1, String city, String state, String zip})?>
    fetchAddressDetails(String placeId) async {
  try {
    final res = await http.get(
      Uri.parse('https://places.googleapis.com/v1/places/$placeId'),
      headers: {
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'addressComponents',
      },
    );
    if (res.statusCode != 200) return null;

    final decoded = json.decode(res.body) as Map<String, dynamic>;
    final components = (decoded['addressComponents'] as List?) ?? const [];

    String long(String type, {bool short = false}) {
      for (final c in components) {
        if (c is! Map<String, dynamic>) continue;
        final types = (c['types'] as List?)?.cast<dynamic>() ?? const [];
        if (types.contains(type)) {
          final key = short ? 'shortText' : 'longText';
          return (c[key] as String?)?.trim() ?? '';
        }
      }
      return '';
    }

    final streetNumber = long('street_number');
    final route = long('route');
    final line1 = '$streetNumber $route'.trim();

    var city = long('locality');
    if (city.isEmpty) city = long('postal_town');
    if (city.isEmpty) city = long('sublocality');

    final state = long('administrative_area_level_1');
    final zip = long('postal_code');

    return (line1: line1, city: city, state: state, zip: zip);
  } catch (_) {
    return null;
  }
}

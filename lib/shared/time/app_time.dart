import 'package:timezone/timezone.dart' as tz;

/// Timezone-aware time helpers. Every booking/availability calculation must go
/// through here using the *community's* timezone (PROJECT-BRIEF §10) — never
/// the device local time, or residents in other zones would see wrong slots.
class AppTime {
  const AppTime._();

  /// `now` in the given IANA timezone (e.g. `America/Chicago`).
  static tz.TZDateTime now(String timezoneName) =>
      tz.TZDateTime.now(_location(timezoneName));

  /// Interpret a UTC [DateTime] in the community's timezone.
  static tz.TZDateTime inZone(DateTime utc, String timezoneName) =>
      tz.TZDateTime.from(utc.toUtc(), _location(timezoneName));

  static tz.Location _location(String name) {
    try {
      return tz.getLocation(name);
    } catch (_) {
      return tz.getLocation('Etc/UTC');
    }
  }
}

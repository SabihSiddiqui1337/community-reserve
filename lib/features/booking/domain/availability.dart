import '../../amenities/domain/amenity.dart';

/// A busy time-range for an amenity (from the `getAvailability` function).
/// Carries only time + court — never private reservation data.
class BusyInterval {
  const BusyInterval({required this.start, required this.end, this.court});
  final DateTime start;
  final DateTime end;
  final int? court;

  factory BusyInterval.fromJson(Map<String, dynamic> json) => BusyInterval(
        start: DateTime.parse(json['start'] as String).toLocal(),
        end: DateTime.parse(json['end'] as String).toLocal(),
        court: (json['court'] as num?)?.toInt(),
      );
}

/// A single bookable time slot with its current occupancy.
class Slot {
  const Slot({
    required this.start,
    required this.end,
    required this.booked,
    required this.capacity,
    this.bookedCourts = const {},
  });

  final DateTime start;
  final DateTime end;
  final int booked;
  final int capacity;
  final Set<int> bookedCourts;

  bool get isAvailable => booked < capacity;
  int get remaining => capacity - booked;
}

/// Generate the day's slots for an amenity from its open hours / slot length /
/// capacity, folding in the busy intervals to compute remaining capacity.
List<Slot> computeDaySlots(
  Amenity amenity,
  DateTime day,
  List<BusyInterval> busy,
) {
  final slots = <Slot>[];
  final openMin = amenity.openHour * 60;
  final closeMin = amenity.closeHour * 60;
  final step = amenity.slotMinutes <= 0 ? 60 : amenity.slotMinutes;

  for (var m = openMin; m + step <= closeMin; m += step) {
    final start = DateTime(day.year, day.month, day.day).add(
      Duration(minutes: m),
    );
    final end = start.add(Duration(minutes: step));

    final overlapping =
        busy.where((b) => b.start.isBefore(end) && b.end.isAfter(start));
    final courts = <int>{
      for (final b in overlapping) if (b.court != null) b.court!
    };

    slots.add(Slot(
      start: start,
      end: end,
      booked: overlapping.length,
      capacity: amenity.capacity,
      bookedCourts: courts,
    ));
  }
  return slots;
}

import '../../amenities/domain/amenity.dart';
import '../../reservations/domain/reservation.dart';

/// A single bookable time slot with its current occupancy.
class Slot {
  const Slot({
    required this.start,
    required this.end,
    required this.booked,
    required this.capacity,
  });

  final DateTime start;
  final DateTime end;
  final int booked;
  final int capacity;

  bool get isAvailable => booked < capacity;
  int get remaining => capacity - booked;
}

/// Statuses that still occupy a slot (anything live/upcoming).
const _occupying = {
  ReservationStatus.booked,
  ReservationStatus.checkedIn,
  ReservationStatus.completed,
};

/// Generate the day's slots for an amenity from its open hours / slot length /
/// capacity, folding in existing reservations to compute remaining capacity.
///
/// NOTE: slots are built in the device's local time; the demo communities use
/// a single timezone. Full per-tenant tz handling lives in `shared/time`.
List<Slot> computeDaySlots(
  Amenity amenity,
  DateTime day,
  List<Reservation> dayReservations,
) {
  final slots = <Slot>[];
  final openMin = amenity.openHour * 60;
  final closeMin = amenity.closeHour * 60;
  final step = amenity.slotMinutes <= 0 ? 60 : amenity.slotMinutes;

  for (var m = openMin; m + step <= closeMin; m += step) {
    final start = DateTime(day.year, day.month, day.day, 0, 0).add(
      Duration(minutes: m),
    );
    final end = start.add(Duration(minutes: step));

    final booked = dayReservations.where((r) {
      if (!_occupying.contains(r.status)) return false;
      if (r.startTime == null || r.endTime == null) return false;
      return r.startTime!.isBefore(end) && r.endTime!.isAfter(start);
    }).length;

    slots.add(Slot(
      start: start,
      end: end,
      booked: booked,
      capacity: amenity.capacity,
    ));
  }
  return slots;
}

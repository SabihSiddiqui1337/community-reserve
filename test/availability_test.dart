import 'package:amenry/features/amenities/domain/amenity.dart';
import 'package:amenry/features/booking/domain/availability.dart';
import 'package:amenry/features/reservations/domain/reservation.dart';
import 'package:amenry/shared/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeDaySlots', () {
    const amenity = Amenity(
      id: 'a',
      name: 'Court',
      slotMinutes: 60,
      capacity: 2,
      openHour: 8,
      closeHour: 12,
    );
    final day = DateTime(2026, 6, 20);

    test('generates one slot per open hour', () {
      final slots = computeDaySlots(amenity, day, const []);
      expect(slots.length, 4); // 8,9,10,11
      expect(slots.first.start.hour, 8);
      expect(slots.last.end.hour, 12);
    });

    test('counts overlapping reservations against capacity', () {
      final overlapping = Reservation(
        id: 'r',
        amenityId: 'a',
        userId: 'u',
        startTime: DateTime(2026, 6, 20, 8),
        endTime: DateTime(2026, 6, 20, 9),
      );
      final slots = computeDaySlots(amenity, day, [overlapping]);
      final eight = slots.firstWhere((s) => s.start.hour == 8);
      expect(eight.booked, 1);
      expect(eight.remaining, 1);
      expect(eight.isAvailable, isTrue); // capacity 2

      final nine = slots.firstWhere((s) => s.start.hour == 9);
      expect(nine.booked, 0);
    });

    test('cancelled reservations do not occupy a slot', () {
      final cancelled = Reservation(
        id: 'r',
        amenityId: 'a',
        userId: 'u',
        status: ReservationStatus.cancelled,
        startTime: DateTime(2026, 6, 20, 8),
        endTime: DateTime(2026, 6, 20, 9),
      );
      final slots = computeDaySlots(amenity, day, [cancelled]);
      expect(slots.firstWhere((s) => s.start.hour == 8).booked, 0);
    });
  });

  test('Money formats integer cents', () {
    expect(Money.format(7500), r'$75.00');
    expect(Money.format(0), r'$0.00');
  });
}

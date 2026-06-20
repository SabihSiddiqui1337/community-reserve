import 'package:amenry/features/amenities/domain/amenity.dart';
import 'package:amenry/features/booking/domain/availability.dart';
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

    test('counts overlapping busy intervals against capacity', () {
      final busy = [
        BusyInterval(
          start: DateTime(2026, 6, 20, 8),
          end: DateTime(2026, 6, 20, 9),
          court: 1,
        ),
      ];
      final slots = computeDaySlots(amenity, day, busy);
      final eight = slots.firstWhere((s) => s.start.hour == 8);
      expect(eight.booked, 1);
      expect(eight.remaining, 1);
      expect(eight.isAvailable, isTrue); // capacity 2
      expect(eight.bookedCourts, {1});

      final nine = slots.firstWhere((s) => s.start.hour == 9);
      expect(nine.booked, 0);
    });

    test('a fully-booked hour is unavailable', () {
      final busy = [
        for (var c = 1; c <= 2; c++)
          BusyInterval(
            start: DateTime(2026, 6, 20, 10),
            end: DateTime(2026, 6, 20, 11),
            court: c,
          ),
      ];
      final slots = computeDaySlots(amenity, day, busy);
      final ten = slots.firstWhere((s) => s.start.hour == 10);
      expect(ten.isAvailable, isFalse);
      expect(ten.bookedCourts, {1, 2});
    });
  });

  test('Money formats integer cents', () {
    expect(Money.format(500), r'$5.00');
    expect(Money.format(0), r'$0.00');
  });
}

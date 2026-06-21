/// Amenity types eligible for a prorated, per-minute cancellation refund.
/// (Event Hall and other spaces are non-refundable.)
const refundableAmenityTypes = {'basketball', 'pickleballCourt'};

/// Prorated cancellation refund, in cents. You keep the minutes already used
/// and get the remaining minutes back:
///   - cancel before it starts  → full refund
///   - cancel after it ends     → nothing
///   - cancel midway            → refund × (minutes remaining / total minutes)
///
/// Only basketball & pickleball are refundable; everything else returns 0.
/// Mirror of the server calc in functions/src/lib/refund.ts — keep in sync.
int proratedRefundCents({
  required String amenityType,
  required int amountCentsPerHour,
  required DateTime start,
  required DateTime end,
  DateTime? now,
}) {
  if (!refundableAmenityTypes.contains(amenityType)) return 0;
  final totalMinutes = end.difference(start).inMinutes;
  if (totalMinutes <= 0 || amountCentsPerHour <= 0) return 0;

  final paid = (amountCentsPerHour * (totalMinutes / 60.0)).round();
  final at = now ?? DateTime.now();
  if (!at.isAfter(start)) return paid; // not started yet → full refund
  if (!at.isBefore(end)) return 0; // already ended → nothing

  final remainingMinutes = end.difference(at).inMinutes;
  return (paid * remainingMinutes / totalMinutes).round().clamp(0, paid);
}

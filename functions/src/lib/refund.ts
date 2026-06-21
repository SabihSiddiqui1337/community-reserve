/** Amenity types eligible for a prorated, per-minute cancellation refund. */
const REFUNDABLE_TYPES = new Set(["basketball", "pickleballCourt"]);

/**
 * Prorated cancellation refund, in cents. You keep the minutes already used and
 * get the remaining minutes back:
 *   - cancel before start → full refund
 *   - cancel after end    → nothing
 *   - cancel midway       → refund × (minutes remaining / total minutes)
 *
 * Only basketball & pickleball are refundable; everything else returns 0.
 * Mirror of the client calc in lib/features/reservations/domain/refund.dart.
 */
export function proratedRefundCents(params: {
  amenityType: string;
  amountCentsPerHour: number;
  start: Date;
  end: Date;
  now?: Date;
}): number {
  const { amenityType, amountCentsPerHour, start, end } = params;
  if (!REFUNDABLE_TYPES.has(amenityType)) return 0;

  const totalMinutes = Math.round((end.getTime() - start.getTime()) / 60_000);
  if (totalMinutes <= 0 || amountCentsPerHour <= 0) return 0;

  const paid = Math.round(amountCentsPerHour * (totalMinutes / 60));
  const now = params.now ?? new Date();
  if (now <= start) return paid; // not started → full refund
  if (now >= end) return 0; // already ended → nothing

  const remaining = Math.round((end.getTime() - now.getTime()) / 60_000);
  const refund = Math.round((paid * remaining) / totalMinutes);
  return Math.max(0, Math.min(paid, refund));
}

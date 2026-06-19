/**
 * Pure booking-rule checks (PROJECT-BRIEF §4.1). Kept side-effect free so they
 * can be unit-tested and reused by the createReservation callable. Phase 2
 * wires these against live Firestore aggregates.
 */

export interface CommunitySettings {
  maxBookingHoursPerWeek: number;
  advanceBookingDays: number;
  maxActiveReservationsPerUser: number;
  checkInGraceMinutes: number;
  noShowThreshold: number;
  noShowBanDays: number;
  cancellationCutoffMinutes: number;
}

export interface BookingContext {
  now: Date;
  start: Date;
  end: Date;
  bookedHoursThisWeek: number;
  activeReservations: number;
  amenityStatus: "active" | "comingSoon" | "maintenance";
  residencyStatus: "pending" | "verified" | "rejected";
  bannedUntil: Date | null;
}

export interface RuleViolation {
  code: string;
  message: string;
}

/** Returns every rule the request violates (empty array = OK to book). */
export function validateBooking(
  ctx: BookingContext,
  settings: CommunitySettings
): RuleViolation[] {
  const v: RuleViolation[] = [];

  if (ctx.residencyStatus !== "verified") {
    v.push({ code: "not-verified", message: "Residency is not verified." });
  }
  if (ctx.bannedUntil && ctx.bannedUntil > ctx.now) {
    v.push({ code: "banned", message: "Account is temporarily banned." });
  }
  if (ctx.amenityStatus !== "active") {
    v.push({ code: "amenity-unavailable", message: "Amenity is not active." });
  }

  const requestedHours = (ctx.end.getTime() - ctx.start.getTime()) / 3_600_000;
  if (ctx.bookedHoursThisWeek + requestedHours > settings.maxBookingHoursPerWeek) {
    v.push({ code: "weekly-cap", message: "Exceeds weekly hour cap." });
  }
  if (ctx.activeReservations >= settings.maxActiveReservationsPerUser) {
    v.push({ code: "max-active", message: "Too many active reservations." });
  }

  const advanceMs = ctx.start.getTime() - ctx.now.getTime();
  const maxAdvanceMs = settings.advanceBookingDays * 86_400_000;
  if (advanceMs > maxAdvanceMs) {
    v.push({ code: "advance-window", message: "Outside the booking window." });
  }

  return v;
}

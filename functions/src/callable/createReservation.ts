import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { db, paths } from "../lib/firebase";
import {
  validateBooking,
  CommunitySettings,
} from "../domain/bookingRules";
import { generatePin, hashPin } from "../domain/pin";
import { signQrToken } from "../domain/qrToken";
import { MockAccessProvider } from "../access/MockAccessProvider";

const OCCUPYING = ["booked", "checkedIn", "completed"];

/** Sales-tax rate applied at checkout (matches the client booking flow). */
const TAX_RATE = 0.0825;

function normalizeSettings(s: Record<string, unknown>): CommunitySettings {
  return {
    maxBookingHoursPerWeek: (s.maxBookingHoursPerWeek as number) ?? 3,
    advanceBookingDays: (s.advanceBookingDays as number) ?? 7,
    maxActiveReservationsPerUser: (s.maxActiveReservationsPerUser as number) ?? 2,
    checkInGraceMinutes: (s.checkInGraceMinutes as number) ?? 15,
    noShowThreshold: (s.noShowThreshold as number) ?? 3,
    noShowBanDays: (s.noShowBanDays as number) ?? 30,
    cancellationCutoffMinutes: (s.cancellationCutoffMinutes as number) ?? 60,
  };
}

/**
 * Create a reservation (PROJECT-BRIEF §4.1/§4.2). Enforces residency, ban,
 * weekly cap, advance window, max-active and capacity SERVER-SIDE, then issues
 * a hashed PIN + signed QR and provisions a (mock) access credential.
 * Returns { reservationId, pin } — the raw PIN is returned once and never
 * stored.
 */
export const createReservation = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in to book.");

  const { communityId, amenityId, startTime, endTime, paymentId, court, paymentMethod } =
    request.data ?? {};
  if (!communityId || !amenityId || !startTime || !endTime) {
    throw new HttpsError("invalid-argument", "Missing booking fields.");
  }
  const requestedCourt: number | null =
    typeof court === "number" ? court : null;
  const start = new Date(startTime);
  const end = new Date(endTime);
  if (isNaN(start.getTime()) || isNaN(end.getTime()) || end <= start) {
    throw new HttpsError("invalid-argument", "Invalid time window.");
  }

  const communitySnap = await paths.community(communityId).get();
  if (!communitySnap.exists) {
    throw new HttpsError("not-found", "Community not found.");
  }
  const settings = normalizeSettings(
    (communitySnap.data()!.settings ?? {}) as Record<string, unknown>
  );

  const membershipSnap = await paths.memberships(communityId).doc(uid).get();
  const membership = membershipSnap.data();
  if (!membership) throw new HttpsError("permission-denied", "Not a member.");

  const amenitySnap = await paths.amenities(communityId).doc(amenityId).get();
  const amenity = amenitySnap.data();
  if (!amenity) throw new HttpsError("not-found", "Amenity not found.");

  // Aggregate the user's weekly hours and active reservations.
  const now = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 86_400_000);
  const userRes = await paths
    .reservations(communityId)
    .where("userId", "==", uid)
    .get();
  let bookedHoursThisWeek = 0;
  let activeReservations = 0;
  for (const d of userRes.docs) {
    const r = d.data();
    const s = (r.startTime as Timestamp | undefined)?.toDate();
    const e = (r.endTime as Timestamp | undefined)?.toDate();
    if (OCCUPYING.includes(r.status) && s && e && s >= weekAgo) {
      bookedHoursThisWeek += (e.getTime() - s.getTime()) / 3_600_000;
    }
    if (["booked", "checkedIn"].includes(r.status) && e && e > now) {
      activeReservations++;
    }
  }

  const violations = validateBooking(
    {
      now,
      start,
      end,
      bookedHoursThisWeek,
      activeReservations,
      amenityStatus: amenity.status,
      residencyStatus: membership.residencyStatus,
      bannedUntil: (membership.bannedUntil as Timestamp | null)?.toDate() ?? null,
    },
    settings
  );
  if (violations.length) {
    throw new HttpsError("failed-precondition", violations[0].message, {
      violations,
    });
  }

  // Payment gate (PROJECT-BRIEF §4.1): paid amenity + payments enabled requires
  // a succeeded payment owned by this user before we confirm.
  const paymentsEnabled =
    communitySnap.data()!.featureFlags?.paymentsEnabled === true;
  const isPaid = amenity.pricing?.isPaid === true;
  if (isPaid && paymentsEnabled) {
    if (!paymentId) {
      throw new HttpsError("failed-precondition", "Payment required.");
    }
    const paySnap = await paths.payments(communityId).doc(paymentId).get();
    const pay = paySnap.data();
    if (!pay || pay.userId !== uid || pay.status !== "succeeded") {
      throw new HttpsError("failed-precondition", "Payment not completed.");
    }
  }

  // Price snapshot — capture exactly what is charged so a later tax-toggle
  // never rewrites this booking. Authoritative: derived from the community's
  // CURRENT taxEnabled setting (defaults on).
  const taxEnabled =
    communitySnap.data()!.settings?.taxEnabled !== false;
  const amountCentsPerHour = isPaid
    ? ((amenity.pricing?.amountCents as number) ?? 0)
    : 0;
  // Bill only for time the resident can actually use: the window
  // [billedStart, end] where billedStart = max(slotStart, serverNow). Booking a
  // slot that's already in progress is charged only for the remaining minutes.
  const serverNow = new Date();
  const billedStart =
    serverNow.getTime() > start.getTime() ? serverNow : start;
  const billedMinutes = Math.max(
    0,
    (end.getTime() - billedStart.getTime()) / 60_000
  );
  const subtotalCents = Math.round((amountCentsPerHour * billedMinutes) / 60);
  const taxCents = taxEnabled ? Math.round(subtotalCents * TAX_RATE) : 0;

  const capacity = (amenity.capacity as number) ?? 1;
  const reservationsCol = paths.reservations(communityId);
  const reservationId = reservationsCol.doc().id;

  const pin = generatePin();
  const { pinHash, salt } = hashPin(pin);
  const qrToken = signQrToken({ reservationId, communityId }, end);

  // Capacity check + create atomically.
  await db.runTransaction(async (tx) => {
    const overlapSnap = await tx.get(
      reservationsCol
        .where("amenityId", "==", amenityId)
        .where("startTime", "<", Timestamp.fromDate(end))
    );
    const overlapping = overlapSnap.docs.filter((d) => {
      const r = d.data();
      const e = (r.endTime as Timestamp | undefined)?.toDate();
      return OCCUPYING.includes(r.status) && e && e > start;
    });
    if (overlapping.length >= capacity) {
      throw new HttpsError("failed-precondition", "That slot is full.");
    }

    // Court assignment: honor the requested court if free, else lowest free.
    const bookedCourts = new Set<number>();
    for (const d of overlapping) {
      const c = d.data().court as number | undefined;
      if (c) bookedCourts.add(c);
    }
    let assignedCourt = requestedCourt;
    if (assignedCourt) {
      if (bookedCourts.has(assignedCourt)) {
        throw new HttpsError("failed-precondition", "That court is taken.");
      }
    } else {
      for (let c = 1; c <= capacity; c++) {
        if (!bookedCourts.has(c)) {
          assignedCourt = c;
          break;
        }
      }
    }

    tx.set(reservationsCol.doc(reservationId), {
      amenityId,
      userId: uid,
      court: assignedCourt ?? 1,
      startTime: Timestamp.fromDate(start),
      endTime: Timestamp.fromDate(end),
      status: "booked",
      pinHash,
      salt,
      qrToken,
      accessCredentialId: null,
      checkedInAt: null,
      createdAt: Timestamp.now(),
      cancelledAt: null,
      paymentId: paymentId ?? null,
      paymentMethod: typeof paymentMethod === "string" ? paymentMethod : null,
      subtotalCents,
      taxCents,
    });
  });

  // Link the payment to its reservation.
  if (paymentId) {
    await paths
      .payments(communityId)
      .doc(paymentId)
      .update({ reservationId });
  }

  // Provision a (mock) door credential for the window.
  const access = new MockAccessProvider();
  const credential = await access.provisionCredential({
    reservationId,
    communityId,
    amenityId,
    startTime: start,
    endTime: end,
  });
  await reservationsCol.doc(reservationId).update({
    accessCredentialId: credential.accessCredentialId,
  });

  return { reservationId, pin, qrToken };
});

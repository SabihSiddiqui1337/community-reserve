import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp, FieldValue } from "firebase-admin/firestore";

import { paths } from "../lib/firebase";
import { MockAccessProvider } from "../access/MockAccessProvider";
import { notifyWaitlist } from "../lib/notify";

/** Sales-tax rate (only used to reconstruct snapshots on legacy docs). */
const TAX_RATE = 0.0825;
const clamp01 = (x: number) => Math.max(0, Math.min(1, x));

/**
 * Cancel a reservation (PROJECT-BRIEF §4.6). Free cancellation up to
 * `cancellationCutoffMinutes` before start; a later cancellation counts as a
 * no-show (default). Releases the slot and revokes the access credential.
 */
export const cancelReservation = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Auth required.");

  const { communityId, reservationId } = request.data ?? {};
  if (!communityId || !reservationId) {
    throw new HttpsError("invalid-argument", "Missing fields.");
  }

  const ref = paths.reservations(communityId).doc(reservationId);
  const snap = await ref.get();
  const res = snap.data();
  if (!res) throw new HttpsError("not-found", "Reservation not found.");
  if (res.userId !== uid) {
    throw new HttpsError("permission-denied", "Not your reservation.");
  }
  if (res.status !== "booked" && res.status !== "checkedIn") {
    throw new HttpsError("failed-precondition", "Cannot cancel this booking.");
  }

  const communitySnap = await paths.community(communityId).get();
  const cutoffMinutes =
    (communitySnap.data()?.settings?.cancellationCutoffMinutes as number) ?? 60;
  const allowance =
    (communitySnap.data()?.settings?.cancellationAllowance as number) ?? 2;

  const start = (res.startTime as Timestamp).toDate();
  const end = (res.endTime as Timestamp).toDate();
  // The billed window is [billedStart, end] where billedStart = max(slotStart,
  // bookingTime). createdAt ≈ booking time; a slot booked after it began was
  // only charged for the remaining minutes, so proration must use that window.
  const createdAt =
    (res.createdAt as Timestamp | undefined)?.toDate() ?? start;
  const billedStart =
    createdAt.getTime() > start.getTime() ? createdAt : start;
  const minutesToStart = (start.getTime() - Date.now()) / 60_000;
  const isLate = minutesToStart < cutoffMinutes;

  // A cancellation only counts toward the resident's cancellation count when it
  // happens at or after the reservation start time. Cancelling before start is
  // always free and never counts (PROJECT-BRIEF §4.6).
  const counted = Date.now() >= start.getTime();

  // Price snapshot taken at booking time is authoritative — never the current
  // tax setting. Fall back to recomputing from the amenity price + the
  // reservation's own tax decision for older docs that predate the snapshot.
  let subtotalCents = res.subtotalCents as number | undefined;
  let taxCents = res.taxCents as number | undefined;
  if (subtotalCents === undefined || taxCents === undefined) {
    const amenitySnap = await paths
      .amenities(communityId)
      .doc(res.amenityId as string)
      .get();
    const amenity = amenitySnap.data();
    const isPaid = amenity?.pricing?.isPaid === true;
    const amountCentsPerHour = isPaid
      ? ((amenity?.pricing?.amountCents as number) ?? 0)
      : 0;
    const billedMinutes = Math.max(
      0,
      (end.getTime() - billedStart.getTime()) / 60_000
    );
    const recomputedSubtotal = Math.round(
      (amountCentsPerHour * billedMinutes) / 60
    );
    subtotalCents = subtotalCents ?? recomputedSubtotal;
    // No stored tax decision for legacy docs → assume tax was charged.
    taxCents = taxCents ?? Math.round(recomputedSubtotal * TAX_RATE);
  }

  // Prorated cancellation refund from the snapshot, over the BILLED window
  // [billedStart, end]:
  //   - cancel BEFORE billedStart → full refund (subtotal + tax)
  //   - cancel AT/AFTER billedStart → keep the used fraction, refund the rest
  //     while preserving the booking-time tax decision.
  const billedMinutes = Math.max(
    1,
    (end.getTime() - billedStart.getTime()) / 60_000
  );
  const elapsedMinutes = Math.max(
    0,
    (Date.now() - billedStart.getTime()) / 60_000
  );
  const usedFraction = clamp01(elapsedMinutes / billedMinutes);
  const keptSubtotal = Math.round(subtotalCents * usedFraction);
  const keptTax = Math.round(
    keptSubtotal * (taxCents / Math.max(subtotalCents, 1))
  );
  const chargedCents = keptSubtotal + keptTax;
  const refundCents = subtotalCents + taxCents - chargedCents;

  await ref.update({
    status: "cancelled",
    cancelledAt: Timestamp.now(),
    refundCents,
    chargedCents,
  });

  // Record the refund against the payment (demo — payments are stubbed).
  if (refundCents > 0 && res.paymentId) {
    await paths
      .payments(communityId)
      .doc(res.paymentId as string)
      .set(
        { refundedCents: refundCents, status: "refunded" },
        { merge: true }
      );
  }

  // Late cancellation counts toward no-show standing.
  if (isLate) {
    await paths
      .memberships(communityId)
      .doc(uid)
      .update({ noShowCount: FieldValue.increment(1) });
  }

  // At/after start → increment the canceller's cancellation count. Read the
  // current value first so we can report the post-increment total back.
  const membershipRef = paths.memberships(communityId).doc(uid);
  let cancellationCount =
    (((await membershipRef.get()).data()?.cancellationCount as number) ?? 0);
  if (counted) {
    await membershipRef.update({
      cancellationCount: FieldValue.increment(1),
    });
    cancellationCount += 1;
  }

  // Release the door credential.
  await new MockAccessProvider().revokeCredential({
    reservationId,
    communityId,
    amenityId: res.amenityId,
    startTime: start,
    endTime: end,
  });

  // Ping the waitlist for the freed window.
  await notifyWaitlist(communityId, res.amenityId as string, start, end);

  return {
    cancelled: true,
    countedAsNoShow: isLate,
    refundCents,
    chargedCents,
    counted,
    cancellationCount,
    allowance,
  };
});

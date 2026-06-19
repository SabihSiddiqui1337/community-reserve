import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp, FieldValue } from "firebase-admin/firestore";

import { paths } from "../lib/firebase";
import { MockAccessProvider } from "../access/MockAccessProvider";
import { notifyWaitlist } from "../lib/notify";

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

  const start = (res.startTime as Timestamp).toDate();
  const minutesToStart = (start.getTime() - Date.now()) / 60_000;
  const isLate = minutesToStart < cutoffMinutes;

  await ref.update({
    status: "cancelled",
    cancelledAt: Timestamp.now(),
  });

  // Late cancellation counts toward no-show standing.
  if (isLate) {
    await paths
      .memberships(communityId)
      .doc(uid)
      .update({ noShowCount: FieldValue.increment(1) });
  }

  // Release the door credential.
  const end = (res.endTime as Timestamp).toDate();
  await new MockAccessProvider().revokeCredential({
    reservationId,
    communityId,
    amenityId: res.amenityId,
    startTime: start,
    endTime: end,
  });

  // Ping the waitlist for the freed window.
  await notifyWaitlist(communityId, res.amenityId as string, start, end);

  return { cancelled: true, countedAsNoShow: isLate };
});

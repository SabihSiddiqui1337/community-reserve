import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { paths } from "../lib/firebase";

/**
 * Join the waitlist for a full amenity/window (PROJECT-BRIEF §4.5). When a slot
 * is later released (no-show or cancellation), the FIFO waitlist is notified.
 */
export const joinWaitlist = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Auth required.");

  const { communityId, amenityId, desiredStart, desiredEnd } =
    request.data ?? {};
  if (!communityId || !amenityId || !desiredStart || !desiredEnd) {
    throw new HttpsError("invalid-argument", "Missing fields.");
  }
  const start = new Date(desiredStart);
  const end = new Date(desiredEnd);
  if (isNaN(start.getTime()) || isNaN(end.getTime()) || end <= start) {
    throw new HttpsError("invalid-argument", "Invalid window.");
  }

  // Avoid duplicate waiting entries for the same user/amenity/start.
  const existing = await paths
    .waitlist(communityId)
    .where("userId", "==", uid)
    .where("amenityId", "==", amenityId)
    .where("status", "==", "waiting")
    .get();
  const dup = existing.docs.some(
    (d) => (d.data().desiredStart as Timestamp)?.toDate().getTime() ===
      start.getTime()
  );
  if (dup) return { joined: true, duplicate: true };

  const ref = paths.waitlist(communityId).doc();
  await ref.set({
    amenityId,
    userId: uid,
    desiredStart: Timestamp.fromDate(start),
    desiredEnd: Timestamp.fromDate(end),
    status: "waiting",
    createdAt: Timestamp.now(),
  });
  return { joined: true, waitlistId: ref.id };
});

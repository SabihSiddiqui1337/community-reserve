import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { paths } from "../lib/firebase";

const OCCUPYING = ["booked", "checkedIn", "completed"];

/**
 * Returns the busy intervals for an amenity on a given day so the client can
 * compute slot availability WITHOUT reading other residents' reservation docs
 * (which carry private PIN/QR data). Members only; returns time + court, no
 * userId. Window is [dayStartIso, dayEndIso).
 */
export const getAvailability = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Auth required.");

  const { communityId, amenityId, dayStartIso, dayEndIso } = request.data ?? {};
  if (!communityId || !amenityId || !dayStartIso || !dayEndIso) {
    throw new HttpsError("invalid-argument", "Missing fields.");
  }

  const membership = await paths.memberships(communityId).doc(uid).get();
  if (!membership.exists) {
    throw new HttpsError("permission-denied", "Not a member.");
  }

  const start = new Date(dayStartIso);
  const end = new Date(dayEndIso);

  const snap = await paths
    .reservations(communityId)
    .where("amenityId", "==", amenityId)
    .where("startTime", ">=", Timestamp.fromDate(start))
    .where("startTime", "<", Timestamp.fromDate(end))
    .get();

  const busy = snap.docs
    .filter((d) => OCCUPYING.includes(d.data().status))
    .map((d) => {
      const r = d.data();
      return {
        start: (r.startTime as Timestamp).toDate().toISOString(),
        end: (r.endTime as Timestamp).toDate().toISOString(),
        court: (r.court as number | undefined) ?? null,
      };
    });

  return { busy };
});

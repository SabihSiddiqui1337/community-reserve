import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { paths } from "../lib/firebase";
import { verifyPin } from "../domain/pin";
import { verifyQrToken } from "../domain/qrToken";

/**
 * Validate a PIN or QR token at the door / kiosk (PROJECT-BRIEF §4.2).
 * Succeeds only when status is booked/checkedIn and `now` is inside
 * [startTime, endTime]. After endTime it fails ("door won't open"). The first
 * successful validation performs check-in (status -> checkedIn), which cancels
 * the grace timer.
 */
export const validateAccess = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Auth required.");

  const { communityId, reservationId, pin, qrToken } = request.data ?? {};
  if (!communityId) throw new HttpsError("invalid-argument", "Missing community.");

  let resId: string | undefined = reservationId;
  if (qrToken) {
    const payload = verifyQrToken(qrToken);
    if (!payload) return { valid: false, reason: "expired" };
    resId = payload.reservationId;
  }
  if (!resId) {
    throw new HttpsError("invalid-argument", "Provide reservationId or qrToken.");
  }

  const ref = paths.reservations(communityId).doc(resId);
  const snap = await ref.get();
  const res = snap.data();
  if (!res) return { valid: false, reason: "not-found" };

  const now = new Date();
  const start = (res.startTime as Timestamp).toDate();
  const end = (res.endTime as Timestamp).toDate();

  if (res.status !== "booked" && res.status !== "checkedIn") {
    return { valid: false, reason: "released" };
  }
  // Allow check-in up to 10 minutes before the start time.
  const CHECKIN_LEAD_MS = 10 * 60_000;
  if (now > end) return { valid: false, reason: "expired" };
  if (now.getTime() < start.getTime() - CHECKIN_LEAD_MS) {
    return { valid: false, reason: "not-started" };
  }

  if (pin) {
    const ok = verifyPin(pin, res.salt as string, res.pinHash as string);
    if (!ok) return { valid: false, reason: "bad-pin" };
  }

  // First valid access = check-in (cancels the grace timer).
  if (res.status === "booked") {
    await ref.update({ status: "checkedIn", checkedInAt: Timestamp.now() });
  }
  return { valid: true, checkedIn: true };
});

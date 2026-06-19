import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { paths } from "../lib/firebase";

/**
 * SCAFFOLD payment (PROJECT-BRIEF §1/Phase 5). Creates a payment record that
 * auto-succeeds — no real charge. A real implementation would create a Stripe
 * PaymentIntent and confirm it client-side before marking succeeded. The data
 * model and booking gate are real so the flow is QA-able today.
 */
export const createPayment = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Auth required.");

  const { communityId, amountCents, currency } = request.data ?? {};
  if (!communityId || amountCents == null) {
    throw new HttpsError("invalid-argument", "Missing payment fields.");
  }

  const ref = paths.payments(communityId).doc();
  await ref.set({
    userId: uid,
    reservationId: null,
    amountCents,
    currency: currency ?? "USD",
    status: "succeeded", // STUB: auto-succeed
    provider: "stripe",
    providerRef: `stub_${ref.id}`,
    createdAt: Timestamp.now(),
  });

  return { paymentId: ref.id, status: "succeeded" };
});

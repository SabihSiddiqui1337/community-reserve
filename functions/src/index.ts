/**
 * Amenry Cloud Functions entry point. All business-rule enforcement is
 * server-side (PROJECT-BRIEF §4) — the client never decides bookings, PINs,
 * no-shows or bans. Functions are stubbed in Phase 0 and implemented per phase.
 */
import { setGlobalOptions } from "firebase-functions/v2";

setGlobalOptions({ region: "us-central1", maxInstances: 10 });

// Callable (client-invoked) functions
export { createReservation } from "./callable/createReservation";
export { validateAccess } from "./callable/validateAccess";
export { cancelReservation } from "./callable/cancelReservation";
export { joinWaitlist } from "./callable/joinWaitlist";
export { createPayment } from "./callable/createPayment";

// Scheduled (background) jobs
export { graceSweep } from "./scheduled/graceSweep";
export { expirySweep } from "./scheduled/expirySweep";
export { reminders } from "./scheduled/reminders";
export { banExpiry } from "./scheduled/banExpiry";

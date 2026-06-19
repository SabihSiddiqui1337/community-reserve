import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import { Timestamp } from "firebase-admin/firestore";

import { db, paths } from "../lib/firebase";
import { createNotification } from "../lib/notify";

/**
 * Reminders — every 5 minutes (PROJECT-BRIEF §5.3). Sends a T-30 "coming up"
 * nudge and an at-start "your slot is active, here's your PIN" message. Each
 * is sent once, guarded by a flag on the reservation.
 */
export const reminders = onSchedule("every 5 minutes", async () => {
  const communities = await db.collection("communities").get();
  const now = Date.now();
  let sent = 0;

  for (const c of communities.docs) {
    const upcoming = await paths
      .reservations(c.id)
      .where("status", "==", "booked")
      .where("startTime", ">", Timestamp.fromMillis(now - 5 * 60_000))
      .get();

    for (const d of upcoming.docs) {
      const r = d.data();
      const start = (r.startTime as Timestamp).toDate().getTime();
      const mins = (start - now) / 60_000;

      if (mins <= 30 && mins > 25 && !r.reminded30) {
        await createNotification(c.id, r.userId, "Upcoming reservation",
          "Your slot starts in about 30 minutes.", "reminder");
        await d.ref.update({ reminded30: true });
        sent++;
      }
      if (mins <= 0 && mins > -5 && !r.remindedStart) {
        await createNotification(c.id, r.userId, "Your slot is active",
          "Open your reservation for your PIN and QR code.", "reminder");
        await d.ref.update({ remindedStart: true });
        sent++;
      }
    }
  }
  logger.info(`reminders sent ${sent} message(s)`);
});

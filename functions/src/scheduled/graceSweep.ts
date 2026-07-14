import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import { Timestamp, FieldValue } from "firebase-admin/firestore";

import { db, paths } from "../lib/firebase";
import { notifyWaitlist } from "../lib/notify";

/**
 * Grace sweep — every minute (PROJECT-BRIEF §4.3/§4.4).
 * Reservations still `booked` past max(startTime, createdAt) +
 * checkInGraceMinutes become `noShow`: the slot frees up, the member's
 * noShowCount increments, and at the threshold they're banned for
 * noShowBanDays.
 */
export const graceSweep = onSchedule("every 1 minutes", async () => {
  const communities = await db.collection("communities").get();
  let processed = 0;

  for (const c of communities.docs) {
    const settings = (c.data().settings ?? {}) as Record<string, number>;
    const grace = settings.checkInGraceMinutes ?? 15;
    const threshold = settings.noShowThreshold ?? 3;
    const banDays = settings.noShowBanDays ?? 30;
    const cutoff = new Date(Date.now() - grace * 60_000);

    const due = await paths
      .reservations(c.id)
      .where("status", "==", "booked")
      .where("startTime", "<", Timestamp.fromDate(cutoff))
      .get();

    for (const d of due.docs) {
      const data = d.data();
      // Late bookings (created mid-slot) get the grace window from creation
      // time instead — booking the 7:00 slot at 7:44 must not be an instant
      // no-show.
      const created = (data.createdAt as Timestamp | undefined)?.toDate();
      if (created && created > cutoff) continue;
      const userId = data.userId as string;
      await d.ref.update({ status: "noShow" });

      // Free slot -> ping the waitlist for that amenity/window.
      await notifyWaitlist(
        c.id,
        data.amenityId as string,
        (data.startTime as Timestamp).toDate(),
        (data.endTime as Timestamp).toDate()
      );

      const mref = paths.memberships(c.id).doc(userId);
      await mref.update({ noShowCount: FieldValue.increment(1) });

      const mSnap = await mref.get();
      const count = (mSnap.data()?.noShowCount as number) ?? 0;
      if (count >= threshold) {
        const banUntil = new Date(Date.now() + banDays * 86_400_000);
        await mref.update({
          bannedUntil: Timestamp.fromDate(banUntil),
          noShowCount: 0,
        });
        await paths.notifications(c.id).add({
          userId,
          title: "Temporary booking ban",
          body: `You've reached ${threshold} no-shows and are paused for ${banDays} days.`,
          createdAt: Timestamp.now(),
          read: false,
          type: "ban",
        });
      }
      processed++;
    }
  }
  logger.info(`graceSweep processed ${processed} no-show(s)`);
});

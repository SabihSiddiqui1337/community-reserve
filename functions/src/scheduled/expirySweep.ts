import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import { Timestamp } from "firebase-admin/firestore";

import { db, paths } from "../lib/firebase";
import { MockAccessProvider } from "../access/MockAccessProvider";

/**
 * Expiry sweep — every 5 minutes (PROJECT-BRIEF §5.2).
 * Mark past-`endTime` reservations as `completed` and revoke their access
 * credentials so a stale credential can never open a door.
 */
export const expirySweep = onSchedule("every 5 minutes", async () => {
  const communities = await db.collection("communities").get();
  const access = new MockAccessProvider();
  const now = Timestamp.now();
  let completed = 0;

  for (const c of communities.docs) {
    const due = await paths
      .reservations(c.id)
      .where("status", "in", ["booked", "checkedIn"])
      .where("endTime", "<", now)
      .get();

    for (const d of due.docs) {
      const r = d.data();
      await d.ref.update({ status: "completed" });
      await access.revokeCredential({
        reservationId: d.id,
        communityId: c.id,
        amenityId: r.amenityId,
        startTime: (r.startTime as Timestamp).toDate(),
        endTime: (r.endTime as Timestamp).toDate(),
      });
      completed++;
    }
  }
  logger.info(`expirySweep completed ${completed} reservation(s)`);
});

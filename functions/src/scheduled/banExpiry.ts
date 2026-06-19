import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import { Timestamp } from "firebase-admin/firestore";

import { db, paths } from "../lib/firebase";

/**
 * Ban expiry — hourly (PROJECT-BRIEF §5.4). Clears `bannedUntil` on
 * memberships whose ban window has elapsed (null values never match `<`).
 */
export const banExpiry = onSchedule("every 60 minutes", async () => {
  const communities = await db.collection("communities").get();
  const now = Timestamp.now();
  let cleared = 0;

  for (const c of communities.docs) {
    const expired = await paths
      .memberships(c.id)
      .where("bannedUntil", "<", now)
      .get();
    for (const d of expired.docs) {
      await d.ref.update({ bannedUntil: null });
      cleared++;
    }
  }
  logger.info(`banExpiry cleared ${cleared} ban(s)`);
});

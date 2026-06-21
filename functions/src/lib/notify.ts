import { Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";

import { db, paths } from "./firebase";

/**
 * Write an in-app inbox notification and best-effort send an FCM push to the
 * user's registered tokens. Push delivery is a no-op in the emulator (no FCM
 * transport); the inbox doc is the reliable channel for now.
 */
export async function createNotification(
  communityId: string,
  userId: string,
  title: string,
  body: string,
  type = "general",
  // Extra string fields stored on the inbox doc AND sent as the FCM `data`
  // payload, so a notification tap can deep-link (e.g. { route, amenityId }).
  data: Record<string, string> = {}
): Promise<void> {
  await paths.notifications(communityId).add({
    userId,
    title,
    body,
    type,
    ...data,
    read: false,
    createdAt: Timestamp.now(),
  });

  try {
    const userSnap = await db.doc(`users/${userId}`).get();
    const tokens = (userSnap.data()?.fcmTokens as string[] | undefined) ?? [];
    if (tokens.length > 0) {
      await getMessaging().sendEachForMulticast({
        tokens,
        notification: { title, body },
        data: { type, ...data },
      });
    }
  } catch (e) {
    logger.warn("FCM push skipped", { error: `${e}` });
  }
}

/**
 * Notify the FIFO waitlist when a slot opens (PROJECT-BRIEF §4.5). Finds
 * `waiting` entries for the amenity whose desired window overlaps the released
 * window, ordered oldest-first, and pings the first one. First to re-book
 * wins — we never auto-assign.
 */
export async function notifyWaitlist(
  communityId: string,
  amenityId: string,
  start: Date,
  end: Date
): Promise<void> {
  const snap = await paths
    .waitlist(communityId)
    .where("amenityId", "==", amenityId)
    .where("status", "==", "waiting")
    .orderBy("createdAt", "asc")
    .get();

  const match = snap.docs.find((d) => {
    const w = d.data();
    const ds = (w.desiredStart as Timestamp | undefined)?.toDate();
    const de = (w.desiredEnd as Timestamp | undefined)?.toDate();
    if (!ds || !de) return false;
    return ds < end && de > start; // overlaps the freed window
  });
  if (!match) return;

  await match.ref.update({ status: "notified" });

  // Enrich the message with the sport name + a human time, and attach a
  // deep-link so tapping the notification opens that sport's booking screen.
  const amenitySnap = await paths.amenities(communityId).doc(amenityId).get();
  const amenityName = (amenitySnap.data()?.name as string) || "A court";
  const tz = (await paths.community(communityId).get()).data()?.timezone as
    | string
    | undefined;
  let when: string;
  try {
    when = new Intl.DateTimeFormat("en-US", {
      weekday: "short",
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
      timeZone: tz,
    }).format(start);
  } catch {
    when = start.toUTCString();
  }

  await createNotification(
    communityId,
    match.data().userId as string,
    `${amenityName} is now available`,
    `Your ${when} slot just opened up. Tap to book it before someone else grabs it.`,
    "waitlist",
    { amenityId, route: `/book/slots/${amenityId}` }
  );
}

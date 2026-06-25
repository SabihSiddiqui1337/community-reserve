import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { getAuth } from "firebase-admin/auth";
import * as logger from "firebase-functions/logger";

import { db, paths } from "../lib/firebase";

const RESEND_API_KEY = defineSecret("RESEND_API_KEY");

/**
 * Admin: remove a resident from a community. Deletes the membership; if the user
 * belongs to no other community, also deletes their profile + Firebase Auth
 * account so the email becomes reusable. Emails the removed member (best-effort).
 */
export const removeMember = onCall(
  { secrets: [RESEND_API_KEY] },
  async (request) => {
    const callerUid = request.auth?.uid;
    if (!callerUid) throw new HttpsError("unauthenticated", "Auth required.");

    const { communityId, userId } = request.data ?? {};
    if (!communityId || !userId) {
      throw new HttpsError("invalid-argument", "Missing communityId/userId.");
    }
    if (userId === callerUid) {
      throw new HttpsError("failed-precondition", "You can't remove yourself.");
    }

    // Authorize: caller must be a community admin or a global superAdmin.
    const [callerMembership, callerUser] = await Promise.all([
      paths.memberships(communityId).doc(callerUid).get(),
      db.doc(`users/${callerUid}`).get(),
    ]);
    const isAdmin = callerMembership.data()?.role === "admin";
    const isSuper = callerUser.data()?.globalRole === "superAdmin";
    if (!isAdmin && !isSuper) {
      throw new HttpsError("permission-denied", "Admins only.");
    }

    // Member details (captured before deletion) for the notification email.
    const [userSnap, communitySnap] = await Promise.all([
      db.doc(`users/${userId}`).get(),
      paths.community(communityId).get(),
    ]);
    const email = userSnap.data()?.email as string | undefined;
    const name = (userSnap.data()?.name as string | undefined) || "there";
    const communityName =
      (communitySnap.data()?.name as string | undefined) || "the community";

    // Remove the membership.
    await paths.memberships(communityId).doc(userId).delete();

    // If they belong to no other community, free the account so the email is
    // reusable for a future sign-up.
    const others = await db
      .collectionGroup("memberships")
      .where("userId", "==", userId)
      .get();
    let accountFreed = false;
    if (others.empty) {
      await db.doc(`users/${userId}`).delete().catch(() => undefined);
      try {
        await getAuth().deleteUser(userId);
        accountFreed = true;
      } catch (e) {
        logger.warn(`removeMember: could not delete auth user ${userId}: ${e}`);
      }
    }

    // Email the removed member (best-effort; never fail the call on email error).
    if (email) {
      const apiKey = RESEND_API_KEY.value();
      if (apiKey) {
        try {
          const res = await fetch("https://api.resend.com/emails", {
            method: "POST",
            headers: {
              Authorization: `Bearer ${apiKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              from: "Amenry <onboarding@resend.dev>",
              to: [email],
              subject: `Your access to ${communityName} has ended`,
              html: `
                <div style="margin:0;padding:24px;background:#f4f5f7;font-family:'Segoe UI',Helvetica,Arial,sans-serif">
                  <div style="max-width:480px;margin:0 auto;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e6e8eb">
                    <div style="background:#15171c;padding:22px 24px;text-align:center">
                      <span style="color:#C8FA4B;font-size:20px;font-weight:800;letter-spacing:.5px">Amenry</span>
                    </div>
                    <div style="padding:28px 24px">
                      <h1 style="font-size:20px;margin:0 0 12px;color:#15171c">Access removed</h1>
                      <p style="color:#374151;font-size:15px;line-height:1.6;margin:0 0 16px">
                        Hi ${name}, your membership to <b>${communityName}</b> has been
                        removed by a community administrator, so you no longer have access
                        to its amenities and bookings.
                      </p>
                      <p style="color:#374151;font-size:15px;line-height:1.6;margin:0">
                        If you think this was a mistake, please reach out to your community
                        administrator. You're welcome to sign up again if you're re-added.
                      </p>
                    </div>
                  </div>
                </div>`,
            }),
          });
          if (!res.ok) {
            logger.error(
              `removeMember email: Resend ${res.status} ${await res.text()}`
            );
          }
        } catch (e) {
          logger.error(`removeMember email failed: ${e}`);
        }
      }
    }

    return { removed: true, accountFreed };
  }
);

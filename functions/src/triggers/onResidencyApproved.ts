import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";

import { db } from "../lib/firebase";

// Set with:  firebase functions:secrets:set RESEND_API_KEY
const RESEND_API_KEY = defineSecret("RESEND_API_KEY");

/**
 * Emails a resident when an admin approves their residency (status
 * pending -> verified). Uses Resend (https://resend.com) — a free email API.
 * The "from" address uses Resend's test domain; swap in your own verified
 * domain for production sending to any address.
 */
export const onResidencyApproved = onDocumentUpdated(
  {
    document: "communities/{communityId}/memberships/{userId}",
    secrets: [RESEND_API_KEY],
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    // Only on the pending -> verified transition.
    if (before.residencyStatus === "verified") return;
    if (after.residencyStatus !== "verified") return;

    const { communityId, userId } = event.params as {
      communityId: string;
      userId: string;
    };

    const [userSnap, communitySnap] = await Promise.all([
      db.doc(`users/${userId}`).get(),
      db.doc(`communities/${communityId}`).get(),
    ]);
    const email = userSnap.data()?.email as string | undefined;
    const name = (userSnap.data()?.name as string | undefined) || "there";
    const communityName =
      (communitySnap.data()?.name as string | undefined) || "your community";

    if (!email) {
      logger.warn(`onResidencyApproved: no email for user ${userId}`);
      return;
    }
    const apiKey = RESEND_API_KEY.value();
    if (!apiKey) {
      logger.warn("onResidencyApproved: RESEND_API_KEY not set — skipping email");
      return;
    }

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Amenry <onboarding@resend.dev>",
        to: [email],
        subject: `You're approved for ${communityName}! 🎉`,
        html: `
          <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;color:#0a0a0a">
            <h2>Welcome to ${communityName}!</h2>
            <p>Hi ${name},</p>
            <p>Great news — your residency has been <b>approved</b> by your
               community administrator. You can now log in and start booking
               amenities.</p>
            <p style="margin:24px 0">
              <a href="https://amenry-prod.web.app"
                 style="background:#C8FA4B;color:#0a0a0a;padding:12px 22px;
                        border-radius:10px;text-decoration:none;font-weight:bold">
                Open Amenry
              </a>
            </p>
            <p style="color:#888;font-size:12px">
              If you didn't request this, you can ignore this email.
            </p>
          </div>`,
      }),
    });

    if (!res.ok) {
      logger.error(`onResidencyApproved: Resend ${res.status} ${await res.text()}`);
    } else {
      logger.info(`onResidencyApproved: approval email sent to ${email}`);
    }
  }
);

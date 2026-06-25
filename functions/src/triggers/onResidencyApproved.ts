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
        subject: `Welcome to ${communityName} — you're approved! 🎉`,
        html: `
          <div style="margin:0;padding:24px;background:#f4f5f7;font-family:'Segoe UI',Helvetica,Arial,sans-serif">
            <div style="max-width:480px;margin:0 auto;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e6e8eb">
              <div style="background:#15171c;padding:22px 24px;text-align:center">
                <span style="color:#C8FA4B;font-size:20px;font-weight:800;letter-spacing:.5px">Amenry</span>
              </div>
              <div style="padding:28px 24px">
                <div style="text-align:center;font-size:42px;line-height:1">🎉</div>
                <h1 style="text-align:center;font-size:22px;margin:14px 0 4px;color:#15171c">Welcome to ${communityName}!</h1>
                <p style="text-align:center;color:#6b7280;font-size:14px;margin:0 0 24px">Your residency has been approved.</p>
                <p style="color:#111827;font-size:15px;margin:0 0 12px">Hi ${name},</p>
                <p style="color:#374151;font-size:15px;line-height:1.6;margin:0 0 24px">
                  Great news — your community administrator has <b>approved</b> your residency at
                  <b>${communityName}</b>. You now have full access to book amenities, browse events,
                  and manage your reservations. We're glad to have you! 👋
                </p>
                <div style="text-align:center;margin:0 0 22px">
                  <a href="https://amenry-prod.web.app"
                     style="display:inline-block;background:#C8FA4B;color:#15171c;font-weight:700;font-size:15px;text-decoration:none;padding:14px 30px;border-radius:10px">
                    Sign In to Amenry &rarr;
                  </a>
                </div>
                <div style="background:#f4f5f7;border-radius:10px;padding:14px 16px">
                  <p style="margin:0;color:#374151;font-size:13px;line-height:1.5">
                    📱 <b>Tip:</b> open the link above on your phone and choose
                    <b>Add to Home Screen</b> to use Amenry like an app. Native iOS &amp; Android
                    apps are coming soon to the App Store &amp; Google Play.
                  </p>
                </div>
              </div>
              <div style="padding:16px 24px;border-top:1px solid #e6e8eb;text-align:center">
                <p style="margin:0;color:#9ca3af;font-size:12px;line-height:1.5">
                  You're receiving this because your residency at ${communityName} was approved.
                  If this wasn't you, you can safely ignore this email.
                </p>
              </div>
            </div>
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

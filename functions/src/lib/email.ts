import * as nodemailer from "nodemailer";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";

// Set with:
//   firebase functions:secrets:set GMAIL_USER          (your @gmail.com)
//   firebase functions:secrets:set GMAIL_APP_PASSWORD  (16-char app password)
export const GMAIL_USER = defineSecret("GMAIL_USER");
export const GMAIL_APP_PASSWORD = defineSecret("GMAIL_APP_PASSWORD");

/**
 * Send an HTML email through Gmail SMTP. Unlike Resend's test mode, this can
 * deliver to ANY recipient. No-ops (with a warning) if the secrets aren't set.
 */
export async function sendEmail(opts: {
  to: string;
  subject: string;
  html: string;
}): Promise<void> {
  const user = GMAIL_USER.value();
  const pass = GMAIL_APP_PASSWORD.value();
  if (!user || !pass) {
    logger.warn(
      "sendEmail: Gmail not configured (GMAIL_USER / GMAIL_APP_PASSWORD)"
    );
    return;
  }
  const transport = nodemailer.createTransport({
    service: "gmail",
    auth: { user, pass },
  });
  await transport.sendMail({
    from: `Amenry <${user}>`,
    to: opts.to,
    subject: opts.subject,
    html: opts.html,
  });
}

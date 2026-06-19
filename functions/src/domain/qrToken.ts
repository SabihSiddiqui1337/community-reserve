import jwt from "jsonwebtoken";

/**
 * Signed QR token (PROJECT-BRIEF §4.2). Payload carries the reservationId and
 * an `exp` equal to the reservation window end, so the token — and therefore
 * the door — STOPS working after `endTime`. The QR is validated server-side.
 *
 * NOTE: the signing secret here is a placeholder. Before any real deployment,
 * move it to Secret Manager / functions config and rotate.
 */

const QR_SECRET = process.env.QR_SIGNING_SECRET ?? "dev-only-insecure-secret";

export interface QrPayload {
  reservationId: string;
  communityId: string;
}

/** Sign a token that expires at `windowEnd`. */
export function signQrToken(payload: QrPayload, windowEnd: Date): string {
  const expSeconds = Math.floor(windowEnd.getTime() / 1000);
  return jwt.sign(payload, QR_SECRET, { expiresIn: expSeconds - nowSeconds() });
}

export function verifyQrToken(token: string): QrPayload | null {
  try {
    return jwt.verify(token, QR_SECRET) as QrPayload;
  } catch {
    return null; // expired or tampered → door won't open
  }
}

function nowSeconds(): number {
  return Math.floor(Date.now() / 1000);
}

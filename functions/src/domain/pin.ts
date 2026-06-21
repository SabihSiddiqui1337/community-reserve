import { randomInt, createHash, randomBytes } from "crypto";

/**
 * Temporary access PIN handling (PROJECT-BRIEF §4.2).
 * We NEVER store the raw PIN — only a salted hash. The raw value is returned
 * once to the booking client and shown only while the reservation is active.
 */

export interface HashedPin {
  pinHash: string;
  salt: string;
}

/** Cryptographically-random 4-digit PIN (`0000`–`9999`). */
export function generatePin(): string {
  return randomInt(0, 10_000).toString().padStart(4, "0");
}

export function hashPin(pin: string, salt = randomBytes(16).toString("hex")): HashedPin {
  const pinHash = createHash("sha256").update(`${salt}:${pin}`).digest("hex");
  return { pinHash, salt };
}

export function verifyPin(pin: string, salt: string, expectedHash: string): boolean {
  return hashPin(pin, salt).pinHash === expectedHash;
}

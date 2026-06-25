/**
 * Delete all TEST accounts (everything except the seeded demo accounts) so
 * their emails free up. Removes each user's Auth account, profile doc, and any
 * memberships. Keeps the demo accounts below.
 *
 * Run:  cd scripts/seed
 *       GOOGLE_APPLICATION_CREDENTIALS=serviceAccount.json npx tsx cleanup.ts
 */
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { readFileSync } from "fs";

const KEEP = new Set(
  [
    "owner@amenry.test",
    "admin@maplegrove.test",
    "alex@maplegrove.test",
    "sam@maplegrove.test",
    "admin@oakwood.test",
  ].map((e) => e.toLowerCase())
);

const sa = JSON.parse(readFileSync("serviceAccount.json", "utf8"));
initializeApp({ credential: cert(sa) });
const db = getFirestore();
const auth = getAuth();

async function main() {
  const toDelete: { uid: string; email: string }[] = [];
  let pageToken: string | undefined;
  do {
    const res = await auth.listUsers(1000, pageToken);
    for (const u of res.users) {
      const email = (u.email ?? "").toLowerCase();
      if (!email || !KEEP.has(email)) {
        toDelete.push({ uid: u.uid, email: u.email ?? u.uid });
      }
    }
    pageToken = res.pageToken;
  } while (pageToken);

  for (const { uid, email } of toDelete) {
    const ms = await db
      .collectionGroup("memberships")
      .where("userId", "==", uid)
      .get();
    for (const m of ms.docs) await m.ref.delete();
    await db.doc(`users/${uid}`).delete().catch(() => undefined);
    await auth.deleteUser(uid).catch(() => undefined);
    console.log(`  deleted ${email}`);
  }
  console.log(
    `\nDone — removed ${toDelete.length} test account(s); kept ${KEEP.size} demo accounts.`
  );
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

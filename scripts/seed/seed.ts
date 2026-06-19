/**
 * Seed the Firebase Emulator Suite with demo data so every screen looks real
 * out of the box (PROJECT-BRIEF §10).
 *
 * Seeds TWO tenants to showcase white-labeling:
 *   - Maple Grove HOA  (purple/teal, dark)   join code MAPLE
 *   - Oakwood Villas    (orange/blue, light)  join code OAK
 * Each with amenities, an admin + residents, and sample reservations.
 *
 * Run the emulators first, then:
 *   cd scripts/seed && npm install && npm run seed
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp, Firestore } from "firebase-admin/firestore";
import { getAuth, Auth } from "firebase-admin/auth";

process.env.FIRESTORE_EMULATOR_HOST ??= "localhost:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= "localhost:9099";

const PROJECT_ID = "demo-amenry";
initializeApp({ projectId: PROJECT_ID });
const db: Firestore = getFirestore();
const auth: Auth = getAuth();

function daysFromNow(days: number, hour = 9): Timestamp {
  const d = new Date();
  d.setDate(d.getDate() + days);
  d.setHours(hour, 0, 0, 0);
  return Timestamp.fromDate(d);
}

async function ensureUser(
  uid: string,
  email: string,
  name: string,
  globalRole: "resident" | "superAdmin" = "resident"
): Promise<void> {
  try {
    await auth.createUser({ uid, email, password: "Password123!", displayName: name });
  } catch (e: unknown) {
    if ((e as { code?: string }).code !== "auth/uid-already-exists") {
      console.warn(`auth user ${email}:`, (e as Error).message);
    }
  }
  await db.doc(`users/${uid}`).set(
    { name, email, phone: "", photoUrl: null, fcmTokens: [], globalRole },
    { merge: true }
  );
}

interface AmenitySeed {
  id: string;
  type: string;
  name: string;
  description: string;
  status: "active" | "comingSoon" | "maintenance";
  slotMinutes: number;
  capacity: number;
  isPaid?: boolean;
  amountCents?: number;
}

interface MemberSeed {
  uid: string;
  email: string;
  name: string;
  role: "admin" | "resident";
  residencyStatus: "pending" | "verified" | "rejected";
  unit: string;
}

async function seedCommunity(opts: {
  id: string;
  name: string;
  address: string;
  timezone: string;
  city: string;
  joinCode: string;
  primaryColor: string;
  accentColor: string;
  theme: "dark" | "light";
  paymentsEnabled?: boolean;
  amenities: AmenitySeed[];
  members: MemberSeed[];
}): Promise<void> {
  const cref = db.doc(`communities/${opts.id}`);
  await cref.set({
    name: opts.name,
    address: opts.address,
    timezone: opts.timezone,
    branding: {
      logoUrl: null,
      primaryColor: opts.primaryColor,
      accentColor: opts.accentColor,
      backgroundUrl: null,
      theme: opts.theme,
    },
    settings: {
      maxBookingHoursPerWeek: 3,
      advanceBookingDays: 7,
      maxActiveReservationsPerUser: 2,
      checkInGraceMinutes: 15,
      noShowThreshold: 3,
      noShowBanDays: 30,
      cancellationCutoffMinutes: 60,
    },
    featureFlags: {
      paymentsEnabled: opts.paymentsEnabled ?? false,
      gymEnabled: false,
      waitlistEnabled: true,
    },
  });

  // Public directory entry for the join flow.
  await db.doc(`communityDirectory/${opts.id}`).set({
    name: opts.name,
    city: opts.city,
    logoUrl: null,
    joinCode: opts.joinCode,
    primaryColor: opts.primaryColor,
  });

  for (const a of opts.amenities) {
    await cref.collection("amenities").doc(a.id).set({
      type: a.type,
      name: a.name,
      description: a.description,
      status: a.status,
      slotMinutes: a.slotMinutes,
      bufferMinutes: 0,
      capacity: a.capacity,
      requiresPin: true,
      openHour: 6,
      closeHour: 22,
      pricing: {
        isPaid: a.isPaid ?? false,
        amountCents: a.amountCents ?? 0,
        currency: "USD",
        depositCents: 0,
      },
    });
  }

  for (const m of opts.members) {
    await ensureUser(m.uid, m.email, m.name);
    await cref.collection("memberships").doc(m.uid).set({
      userId: m.uid,
      role: m.role,
      residencyStatus: m.residencyStatus,
      unit: m.unit,
      verificationDocUrl: null,
      reviewedBy: null,
      reviewedAt: null,
      rejectionReason: null,
      noShowCount: 0,
      bannedUntil: null,
    });
  }
}

async function main(): Promise<void> {
  console.log(`Seeding project ${PROJECT_ID} via emulator...`);

  await seedCommunity({
    id: "demo-hoa",
    name: "Maple Grove HOA",
    address: "100 Maplewood Dr, Austin, TX",
    timezone: "America/Chicago",
    city: "Austin, TX",
    joinCode: "MAPLE",
    primaryColor: "#C9A24A",
    accentColor: "#E4C16B",
    theme: "dark",
    paymentsEnabled: true,
    amenities: [
      { id: "pickleball", type: "pickleballCourt", name: "Pickleball Courts", description: "Two championship courts with lights.", status: "active", slotMinutes: 60, capacity: 2 },
      { id: "gym", type: "gym", name: "Fitness Center", description: "Cardio + weights. Coming soon.", status: "comingSoon", slotMinutes: 60, capacity: 10 },
      { id: "hall", type: "hall", name: "Community Hall", description: "Event space for up to 80 guests.", status: "active", slotMinutes: 240, capacity: 1, isPaid: true, amountCents: 7500 },
    ],
    members: [
      { uid: "admin-uid", email: "admin@maplegrove.test", name: "Dana Director", role: "admin", residencyStatus: "verified", unit: "A-1" },
      { uid: "resident1-uid", email: "alex@maplegrove.test", name: "Alex Resident", role: "resident", residencyStatus: "verified", unit: "B-2" },
      { uid: "resident2-uid", email: "sam@maplegrove.test", name: "Sam Resident", role: "resident", residencyStatus: "pending", unit: "C-3" },
    ],
  });

  await seedCommunity({
    id: "oakwood",
    name: "Oakwood Villas",
    address: "55 Oakwood Ln, San Diego, CA",
    timezone: "America/Los_Angeles",
    city: "San Diego, CA",
    joinCode: "OAK",
    primaryColor: "#1FA37A",
    accentColor: "#6FE0B8",
    theme: "dark",
    amenities: [
      { id: "tennis", type: "pickleballCourt", name: "Tennis & Pickleball", description: "Resurfaced courts.", status: "active", slotMinutes: 60, capacity: 3 },
      { id: "pool", type: "generic", name: "Swimming Pool", description: "Heated lap pool.", status: "active", slotMinutes: 60, capacity: 20 },
    ],
    members: [
      { uid: "oak-admin-uid", email: "admin@oakwood.test", name: "Olivia Oak", role: "admin", residencyStatus: "verified", unit: "1A" },
    ],
  });

  // Sample reservations for Maple Grove's Alex.
  const res = db.collection("communities/demo-hoa/reservations");
  await res.doc("res-demo-1").set({
    amenityId: "pickleball", userId: "resident1-uid",
    startTime: daysFromNow(1, 18), endTime: daysFromNow(1, 19),
    status: "booked", pinHash: null, salt: null, qrToken: null,
    accessCredentialId: null, checkedInAt: null, createdAt: Timestamp.now(),
    cancelledAt: null, paymentId: null,
  });

  console.log("✓ Seed complete:");
  console.log("  Maple Grove HOA (demo-hoa)  code MAPLE  — admin@maplegrove.test");
  console.log("  Oakwood Villas (oakwood)    code OAK    — admin@oakwood.test");
  console.log("  residents: alex@ / sam@maplegrove.test   (pw Password123!)");
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error("Seed failed:", e);
    process.exit(1);
  });

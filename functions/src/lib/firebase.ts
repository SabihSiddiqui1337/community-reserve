import { initializeApp, getApps } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// Initialize the Admin SDK exactly once (the emulator may reload modules).
if (getApps().length === 0) {
  initializeApp();
}

export const db = getFirestore();

/** Firestore path helpers — keeps the multi-tenant layout in one place. */
export const paths = {
  community: (cid: string) => db.collection("communities").doc(cid),
  memberships: (cid: string) =>
    db.collection("communities").doc(cid).collection("memberships"),
  amenities: (cid: string) =>
    db.collection("communities").doc(cid).collection("amenities"),
  reservations: (cid: string) =>
    db.collection("communities").doc(cid).collection("reservations"),
  waitlist: (cid: string) =>
    db.collection("communities").doc(cid).collection("waitlist"),
  payments: (cid: string) =>
    db.collection("communities").doc(cid).collection("payments"),
  notifications: (cid: string) =>
    db.collection("communities").doc(cid).collection("notifications"),
};

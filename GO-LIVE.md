# Go Live — make Amenry work anywhere (real Firebase)

Goal of this phase: move off the local emulators onto a **real Firebase project** and
host the **web app** so you can open it from your phone on cellular / any network.
The native **App Store** app is a later phase (see the bottom).

Legend: **[YOU]** = you run it (needs your Google/Firebase account or a billing/console
choice). **[CLAUDE]** = Claude can do it once the project exists.

The app code is already wired for this: `lib/bootstrap.dart` honors
`--dart-define=USE_EMULATORS=false`, and the config files (`firebase.json`,
`firestore.rules`, `firestore.indexes.json`, `storage.rules`, `functions/`) are
deploy-ready. What's left is creating the real project and deploying.

---

## Phase 0 — One-time tools (check you have these)

```bash
node -v            # v20+
flutter --version  # 3.x
firebase --version # if missing:  npm install -g firebase-tools
flutterfire --version  # if missing:  dart pub global activate flutterfire_cli
```

## Phase 1 — Create the project & wire real credentials  **[YOU]**

In the session you can prefix a command with `!` to run it here.

```bash
firebase login                                   # opens browser, sign in
firebase projects:create amenry-prod             # or pick a unique id; note it
flutterfire configure --project=amenry-prod      # select Web (+ iOS/Android later)
```

`flutterfire configure` rewrites `lib/firebase_options.dart` with the REAL keys and
sets `.firebaserc` to your project. ✅ After this, the demo placeholder is gone.

## Phase 2 — Turn on billing & sign-in  **[YOU]** (Firebase Console)

1. **Billing → Blaze plan.** Cloud Functions require it. The free tier is generous;
   at demo scale this stays ~$0. (Console → ⚙ → Usage and billing → Modify plan.)
2. **Authentication → Sign-in method → Email/Password → Enable.** Without this,
   login fails.
3. **Firestore Database → Create database** (production mode, pick a region — e.g.
   `us-central1`; keep it consistent with Functions).
4. **Storage → Get started** (same region).

## Phase 3 — Deploy the backend  **[CLAUDE]** (after Phases 1–2)

```bash
firebase use amenry-prod
firebase deploy --only firestore:rules,firestore:indexes,storage,functions
```

Builds + uploads the security rules, the composite indexes, the Storage rules, and
the Cloud Functions (createReservation, cancelReservation, sweeps, etc.).

## Phase 4 — Seed starter data  **[YOU runs key step, CLAUDE drives]**

So you can log in immediately, seed the demo communities + accounts (Owner / Admin /
residents). You can delete this demo data later.

1. **[YOU]** Console → ⚙ → Project settings → **Service accounts → Generate new
   private key** → save as `scripts/seed/serviceAccount.json` (this file is secret —
   it's git-ignored; never commit it).
2. **[CLAUDE]** run:
   ```bash
   cd scripts/seed
   SEED_PROD=1 FIREBASE_PROJECT=amenry-prod \
     GOOGLE_APPLICATION_CREDENTIALS=serviceAccount.json npm run seed
   ```
   Login after this with `owner@amenry.test` / `Password123!` (or create your own
   account from the Sign-up screen).

## Phase 5 — Build & host the web app  **[CLAUDE]**

```bash
powershell -ExecutionPolicy Bypass -File scripts/build-web-prod.ps1
firebase deploy --only hosting
```

Firebase prints a **Hosting URL** like `https://amenry-prod.web.app`.

## Phase 6 — Use it anywhere ✅

Open that URL on your phone (cellular, any network), add it to your home screen, log
in, browse Book, make a reservation. Because Auth/Firestore/Functions now live on
Google's servers, it works from any IP, any device.

---

## ✅ LIVE — pushing updates later

The app is live at **https://amenry-prod.web.app**. When you change things and want
them on the live site:

- **UI / Dart code:**
  ```bash
  powershell -ExecutionPolicy Bypass -File scripts/build-web-prod.ps1
  firebase deploy --only hosting
  ```
- **Cloud Functions:** `firebase deploy --only functions`
- **Security rules / indexes:** `firebase deploy --only firestore:rules,firestore:indexes,storage`
- **Reset/refresh demo data:** re-run the seed
  ```bash
  cd scripts/seed
  SEED_PROD=1 FIREBASE_PROJECT=amenry-prod GOOGLE_APPLICATION_CREDENTIALS=serviceAccount.json npm run seed
  ```

Local development is unchanged — `scripts/build-web.ps1` + the emulators still work for
day-to-day dev; only the `-prod` script + `firebase deploy` touch the live site.

## Later phase — App Store (native iOS)

This is a separate effort, needs a **Mac with Xcode** and an **Apple Developer
account ($99/yr)**:
1. `flutterfire configure` again, selecting **iOS** (adds the iOS Firebase config).
2. `flutter build ipa` and open in Xcode.
3. Set bundle id, signing, app icons, push (APNs) for notifications.
4. Submit via App Store Connect (TestFlight first).
Android/Play Store is the same idea with `flutter build appbundle` ($25 one-time).

We'll tackle that once the web/live backend is verified.

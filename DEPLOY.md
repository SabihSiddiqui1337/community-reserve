# DEPLOY — Going live (works on any network / device)

The app ships pointed at the **local Firebase Emulator**, which only exists on the dev machine — that's why login/Book fail when you're off that network. To make it work **anywhere**, deploy to a **real Firebase project** + **Firebase Hosting**. This is a one-time setup.

## What's already prepped (in this repo)
- `firebase.json` has a **hosting** block serving `build/web`.
- `lib/bootstrap.dart` uses the real backend when built with `--dart-define=USE_EMULATORS=false` (no code change needed).
- `web/index.html` only runs the emulator-only hacks (clearing the auth session, the cache kill-switch) on **localhost** — production keeps you signed in.
- `scripts/seed/seed.ts` can seed the **real** project (see step 5).

## Steps

### 1. Log in to Firebase  *(you run this — interactive)*
```
firebase login
```

### 2. Create / pick a Firebase project + wire credentials  *(you run this — interactive)*
```
dart pub global activate flutterfire_cli   # first time only
flutterfire configure
```
- Pick **Create a new project** (or an existing one). Note the **project id**.
- Select platforms (at least **web**; add iOS/Android if you'll ship those).
- This overwrites `lib/firebase_options.dart` with your real credentials.

### 3. Enable the Blaze plan  *(you do this in the browser)*
Cloud Functions require **Blaze (pay-as-you-go)** — it has a large free tier (a demo is typically $0).
Firebase Console → your project → ⚙️ **Usage and billing** → **Modify plan** → **Blaze**.

### 4. Build for production + deploy  *(I can run these once steps 1–3 are done)*
```
flutter build web --dart-define=USE_EMULATORS=false --pwa-strategy=none
firebase deploy --only hosting,firestore,functions,storage
```
This publishes the website to `https://<project-id>.web.app` and the backend (rules + functions). That URL works on **any network, any device**.

### 5. Seed initial data (one community + an admin so you can log in)  *(once)*
Download a service-account key: Firebase Console → ⚙️ **Project settings** → **Service accounts** → **Generate new private key** → save as `scripts/seed/service-account.json`.
```
cd scripts/seed
SEED_PROD=1 FIREBASE_PROJECT=<project-id> GOOGLE_APPLICATION_CREDENTIALS=service-account.json npm run seed
```
(After the first real users sign up + an admin approves them, you won't need the demo seed.)
**Do not commit `service-account.json`** — it's a secret.

### 6. Re-deploys later
Just re-run step 4 whenever you change the app. The public URL stays the same.

## Notes
- The local emulator workflow still works for development (`firebase emulators:start` + the local server) — production is a separate target via the `--dart-define`.
- iOS/Android release builds use the same real backend automatically once `flutterfire configure` has run.

# Amenry

White-label, multi-tenant **community amenity reservation** platform. Residents
of an HOA/community reserve shared amenities (pickleball courts, gym, hall) and
receive a **temporary PIN + QR** that only works during their reserved window.
Every community is its own tenant with its own branding and booking rules.

> Codename: **Amenry** (amenity + entry). See `PROJECT-BRIEF.md` for the full spec.

## Stack

- **App:** Flutter · Riverpod · go_router · freezed
- **Backend:** Firebase — Auth, Firestore, Storage, Cloud Functions (TypeScript),
  scheduled functions, FCM
- **Payments:** Stripe (`flutter_stripe`) — scaffold only in MVP
- **QR:** `qr_flutter` (generate) · `mobile_scanner` (scan)
- **Door hardware:** abstraction only (`AccessProvider` + `MockAccessProvider`)

## Status — all phases built ✅ (pending your QA)

| Phase | Scope | State |
|-------|-------|-------|
| 0 | Scaffold, white-label theming, emulator wiring, seed | ✅ |
| 1 | Auth, onboarding gate, join flow, residency + admin approvals | ✅ |
| 2 | Amenities, availability, server-enforced booking/cancel | ✅ |
| 3 | PIN + QR, check-in, grace/expiry/ban sweeps, no-show | ✅ |
| 4 | Waitlist, FIFO notify, in-app inbox, reminders, FCM scaffold | ✅ |
| 5 | Payments scaffold (Stripe stubbed, paid-booking gate) | ✅ |
| 6 | Admin: approvals, amenities CRUD, reservations, reports, branding, rules, members | ✅ |
| 7 | Polish, tests, full QA build | ✅ |

Verified: `flutter analyze` clean · 6 unit tests pass · `flutter build web` OK ·
functions `tsc` clean · **E2E booking/PIN/payment flow exercised against the
emulator** (verified-resident books, pending-resident rejected, quota enforced,
paid-booking gated, PIN check-in valid, wrong PIN rejected).

**Scaffolded (need external accounts to go live, per brief):** real FCM push
delivery, real Stripe charges, door-lock hardware. Their data models, flows and
stubs are in place — a credentials swap activates them.

## QA accounts (emulator, password `Password123!`)

| Email | Role | Community |
|-------|------|-----------|
| `admin@maplegrove.test` | Admin | Maple Grove HOA (code `MAPLE`) |
| `alex@maplegrove.test` | Resident (verified) | Maple Grove HOA |
| `sam@maplegrove.test` | Resident (pending) | Maple Grove HOA |
| `admin@oakwood.test` | Admin | Oakwood Villas (code `OAK`) |

Two tenants with distinct branding demonstrate white-labeling. Sign up a brand-new
account to walk the full onboarding (join → residency → pending → approved).

## Prerequisites

- Flutter 3.44+, Dart 3.12+
- Node 20+ (Cloud Functions / seed)
- Firebase CLI — `npm install -g firebase-tools` (needed for emulators)

## Run it (emulator-only — no Firebase account needed)

```bash
# 1. Install app deps + generate freezed/json code
flutter pub get
dart run build_runner build

# 2. Cloud Functions deps
cd functions && npm install && npm run build && cd ..

# 3. Start the Firebase Emulator Suite (Auth, Firestore, Functions, Storage, UI)
firebase emulators:start

# 4. Seed the demo community (in another terminal, emulators running)
cd scripts/seed && npm install && npm run seed && cd ../..

# 5. Run the app (web is easiest on Windows; or an Android/iOS device)
flutter run -d chrome
```

The app talks to the emulators automatically in debug mode (see
`lib/bootstrap.dart`). If the emulators aren't running, it still boots with the
built-in demo community so the UI is never blank.

## Going live later

Run `flutterfire configure` to replace `lib/firebase_options.dart` with real
project credentials. Until then everything targets the `demo-amenry` demo
project, which can never reach production.

## Layout

```
lib/              Flutter app (feature-first; see ARCHITECTURE.md)
functions/        Cloud Functions (TypeScript) — all business-rule enforcement
scripts/seed/     Emulator seed script
firestore.rules   Multi-tenant isolation + role rules
storage.rules     Residency-doc / branding storage rules
```

See **ARCHITECTURE.md** for structure and conventions, **CLAUDE.md** for
working conventions.

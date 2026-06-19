# Architecture

## Principles

1. **Multi-tenant by construction.** Every record lives under
   `communities/{communityId}/...`. Branding + settings + feature flags load
   per community at runtime and drive the theme and rules. Nothing
   community-specific is hardcoded.
2. **Server-side enforcement.** All business rules (booking eligibility, PINs,
   no-show counting, bans, slot capacity) are enforced in Cloud Functions with
   the Admin SDK. The client is never trusted. Firestore rules are strict and
   most writes are server-only.
3. **Feature-first, layered.** Each feature owns `data / domain / presentation`.
   Cross-cutting time/money math lives in `lib/shared`.

## Flutter app (`lib/`)

```
app/
  app.dart            Root widget — rebuilds theme from active community branding
  router/             go_router config + route constants
  theme/              AppTheme.from(branding) → ThemeData (dark/light), hex parsing
core/
  services/firebase/  Firebase service providers (auth/firestore/storage)
  utils/              Result<T>, shared helpers
  widgets/            Shared UI
shared/
  time/               AppTime — timezone-aware (community tz, never device local)
  money/              Money — integer cents, format only here
features/
  community/          Tenant model + repository + providers (the multi-tenant core)
    domain/           Community, Branding, CommunitySettings, FeatureFlags (freezed)
    data/             CommunityRepository (Firestore)
    application/      tenant_providers (currentCommunityId, activeCommunity)
  auth/ residency/ amenities/ booking/ reservations/ waitlist/
  notifications/ payments/ profile/ home/
  admin/              approvals · amenities_manager · reservations_calendar
                      · reports · branding_editor · members
```

**State:** Riverpod. `currentCommunityProvider` streams the active tenant;
`AmenryApp` watches it and rebuilds `ThemeData` from `branding` — this is the
white-label mechanism. The same binary reskins per community at runtime.

**Models:** freezed + json_serializable. Run codegen after editing any model:
`dart run build_runner build`.

## Backend (`functions/`, TypeScript)

```
src/
  index.ts            Exports all functions; sets region/options
  lib/firebase.ts     Admin SDK init + Firestore path helpers (tenant layout)
  domain/             Pure logic: pin (hash only), qrToken (signed, exp=window end),
                      bookingRules (validateBooking)
  access/             AccessProvider interface + MockAccessProvider (door HW §8)
  callable/           createReservation, validateAccess, cancelReservation, joinWaitlist
  scheduled/          graceSweep(1m), expirySweep(5m), reminders(5m), banExpiry(60m)
```

Functions are stubbed in Phase 0 (auth-guarded, documented per phase) and
implemented in Phases 2–4. Domain helpers (`pin`, `qrToken`, `bookingRules`)
are already real.

## Data model

Firestore collections per `PROJECT-BRIEF.md` §3:
`communities/{cid}` → `branding`, `settings`, `featureFlags`; sub-collections
`memberships`, `amenities`, `reservations`, `waitlist`, `payments`,
`notifications`. Global `users/{uid}`.

## Security

- `firestore.rules` — tenant isolation via membership existence; role checks
  (resident/admin/superAdmin); reservations/waitlist/payments are server-write
  only.
- `storage.rules` — residency docs readable/writable only by their owner;
  branding assets are public-read.

## Door hardware (§8)

`AccessProvider.provisionCredential / revokeCredential`. MVP ships
`MockAccessProvider` (logs only). A real vendor (Kisi/Brivo/Igloohome) plugs in
later without touching the reservation flow — the reservation already carries
`pinHash` / `qrToken` / `accessCredentialId`.

# CLAUDE.md — working conventions for Amenry

Read `PROJECT-BRIEF.md` (the spec) and `ARCHITECTURE.md` (the structure) first.
Build in the phases in the brief §11; **stop at each ⛳ checkpoint** and confirm
before moving on.

## Non-negotiables

- **Multi-tenant always.** Scope every record under
  `communities/{communityId}/...`. Never hardcode community-specific values —
  read from `community.settings` / `featureFlags` / `branding` at runtime.
- **Enforce business rules server-side** (Cloud Functions + Admin SDK). The
  client never decides bookings, PINs, no-shows, or bans. Keep Firestore rules
  strict; reservations/waitlist/payments are server-write only.
- **Timezone-aware.** All time math uses the community's timezone via
  `lib/shared/time/AppTime` — never device-local time.
- **Money in integer cents.** Format only via `lib/shared/money/Money`.
- **Never store raw PINs.** Hash only (`functions/src/domain/pin.ts`).
  QR tokens expire at the reservation window end.

## Conventions

- **Feature-first**: `features/<name>/{data,domain,presentation}`. Shared logic
  in `core/` and `shared/`.
- **State**: Riverpod. Tenant context is `currentCommunityProvider` /
  `activeCommunityProvider` in `features/community/application`.
- **Models**: freezed + json_serializable. After editing a model, run
  `dart run build_runner build`. Colors stored as `#RRGGBB` strings.
- **Functions**: firebase-functions v2 (`onCall`, `onSchedule`). Type-check with
  `npm run typecheck` in `functions/`.

## Commands

```bash
flutter pub get
dart run build_runner build        # regen freezed/json
flutter analyze
firebase emulators:start           # Auth/Firestore/Functions/Storage/UI
cd scripts/seed && npm run seed    # demo community (emulators must be running)
cd functions && npm run build      # compile TS functions
```

## Firebase

Emulator-only for now; `lib/firebase_options.dart` targets the `demo-amenry`
demo project (safe placeholder). `flutterfire configure` swaps in real
credentials when going live. Don't commit real service-account keys.

### Emulator gotchas (learned the hard way)

- **Use `127.0.0.1`, not `localhost`, for emulator hosts on web.** The emulators
  bind to IPv4; `localhost` can resolve to IPv6 `::1` and auth silently falls
  back to production identitytoolkit. `await FirebaseAuth.useAuthEmulator(...)`
  before `runApp`. Do NOT set `authDomain` in the demo options (it triggers the
  web auth-handler that routes to production). See `lib/bootstrap.dart`.
- **Collection-group queries need a recursive-wildcard rule.** The app finds a
  user's communities via `collectionGroup('memberships').where('userId',==,uid)`.
  Firestore only matches that against a `match /{path=**}/memberships/...` rule,
  not the nested per-community rule. See `firestore.rules`.

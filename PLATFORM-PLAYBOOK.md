# PLATFORM PLAYBOOK — Reusable Spec for White-Label, Multi-Tenant, Booking + Access-Control Apps

> **How to use this file:** This is a generic, app-agnostic blueprint distilled from a real build. For a new project, paste this (plus a short "what we're building" paragraph) into Claude Code as the opening prompt. It captures the architecture, the business logic, the data model, and the hard-won gotchas so you never have to re-derive them. Replace the domain nouns (here: *community / resident / amenity / reservation*) with your own (e.g. *org / member / resource / booking*). Everything else is reusable as-is.
>
> Terminology mapping you can swap per project:
> - **community** → tenant / org / property / club
> - **resident / member** → end user
> - **amenity / resource** → the bookable thing (court, room, desk, equipment, table…)
> - **reservation / booking** → the time-slot booking
> - **admin / director** → tenant administrator
> - **super admin** → platform owner (you)

---

## 0. Core principles (the non-negotiables)

1. **Multi-tenant from line one.** Every record is scoped under `tenants/{tenantId}/...`. Never hardcode a tenant-specific value (colors, rules, names) — load it from `tenant.settings` / `featureFlags` / `branding` at runtime.
2. **Server enforces every business rule.** The client never decides bookings, prices, PINs, no-shows, bans, refunds, or cancellations. All mutations that carry rules go through Cloud Functions with the Admin SDK. Security rules stay strict (the sensitive collections are **server-write only**).
3. **Timezone-aware always.** All time math uses the tenant's timezone, never device-local time. Put it behind one helper (`AppTime`).
4. **Money in integer cents.** Never floats for money. Format only through one `Money` helper. Tax/fees computed server-side and echoed to the client.
5. **Secrets are hashed, never stored raw.** PINs/codes are hashed (salt + hash). Tokens (QR/deep-link) are signed and **expire**.
6. **Feature-first folders.** `features/<name>/{data,domain,presentation}` + shared `core/` and `shared/`. State in Riverpod, models in freezed + json_serializable.
7. **Fixed design system.** One dark theme, one accent. Don't reskin per screen; theme once and reuse tokens.

---

## 1. Tech stack (decided, copy as-is unless told otherwise)

- **Client:** Flutter (iOS/Android/Web), Dart, **Riverpod** (state), **go_router** (nav), **freezed + json_serializable** (models), **google_fonts**, **flutter_animate** (micro-animations).
- **Backend:** Firebase — **Auth**, **Firestore**, **Cloud Storage** (uploads), **Cloud Functions (TypeScript, firebase-functions v2)** for rule enforcement, **scheduled functions** for time-based jobs, **FCM** for push.
- **Payments:** Stripe (`flutter_stripe`) — cards + Apple Pay + Google Pay. Scaffold the data model + flow first; wire real charges later behind one repository.
- **Codes/Access:** `qr_flutter` (generate), `mobile_scanner` (scan). Door/lock hardware behind an **AccessProvider abstraction** (mock now, real vendor later).
- **Local dev:** Firebase Emulator Suite (Auth/Firestore/Functions/Storage/UI). Seed script for demo data.

---

## 2. Multi-tenancy (the spine)

- **Scoping:** `tenants/{tenantId}/{users|resources|bookings|memberships|channels|...}`. Cross-tenant data never mixed.
- **Membership join model:** a user can belong to many tenants → `tenants/{tid}/memberships/{uid}`. To find a user's tenants, use a **collection-group query** on `memberships where userId == uid`. (Firestore needs a `match /{path=**}/memberships/...` recursive-wildcard rule for collection-group reads — the per-tenant nested rule alone won't match.)
- **Public discovery directory:** a separate `tenantDirectory/{tid}` doc with **only summary fields** (name, city, logo, joinCode) and **public read** (`allow read: if true`) so the **sign-up screen can list tenants before the user has an account**. (If this is gated on auth, signup search breaks — see Auth.)
- **Runtime theming/flags:** `tenant.branding` (logo/colors/theme) and `tenant.featureFlags` (`paymentsEnabled`, etc.) drive the app at runtime. (We ended up using a *fixed* dark theme + lime accent and removed per-tenant colors — keep the structure but don't over-invest in per-tenant theming unless the product needs it.)
- **Active-tenant providers:** `currentTenantProvider` / `activeTenantProvider` hold the selected tenant; everything reads tenantId from there.

---

## 3. Auth & onboarding

### Sign in / sign up (one tabbed surface)
- A segmented **Login | Sign up** toggle at the top of both screens. Switching tabs should feel like a swap, **not a page push** → register the two routes with **`NoTransitionPage`** in go_router.
- **No "Sign in with Google/Apple"** unless asked. Email/password to start.
- **Remember me** checkbox + **Forgot password?** link (bottom-right of the password field).
- **"Don't have an account? Create an account"** with only the action span in the accent color (Text.rich + TapGestureRecognizer).
- Keep **demo-account chips** on the login screen during development (tap to autofill a role/tenant, then Sign in) — huge QA accelerator. Remove for production.

### Sign up = **tenant-first + full validation**
1. **Search & pick the tenant first.** Load all tenants from the public directory once, then **filter client-side** (substring + word-prefix). Show all by default when the field is empty. (Avoid per-keystroke Firestore range queries — they need composite indexes and can hang.)
2. Only after a tenant is selected do the rest of the fields unlock: **Name, Email, Phone, Password, Confirm password**.
3. Validation: required, valid email, phone ≥ 10 digits, password ≥ 6, passwords match, tenant selected. Surface `email-already-in-use` as a friendly message. (Phone-uniqueness-per-tenant is best-effort; rules usually block reading other members pre-join — guard it and don't block signup.)
4. On submit: create the auth account, create the user profile, then create the **membership (status: pending)** in the chosen tenant. The onboarding-stage stream then routes them forward.

### Forgot-password flow (3 steps, one screen)
1. Enter email or phone → **Send code**. Start a **30-second resend countdown** (disable "Resend" until it hits 0).
2. Enter the 6-digit code → **Verify**.
3. New password + confirm → **Reset**.
- On the emulator there's no real delivery: **generate a local 6-digit code and show it as a `(demo)` hint** so QA can complete the flow. Mark real SMS/email delivery + the actual reset call as `// TODO` behind one service.

### Onboarding-stage router gating
- A single `onboardingStageProvider` (stream) computes where the user is: `signedOut → needsTenant → needsResidency → ready`. The router **redirects** based on it. Allow-list the auth routes (`signIn`, `signUp`, `forgotPassword`) so they aren't bounced.
- **Residency verification:** new members upload a proof doc to Storage; status is `pending → verified | rejected`; an admin approves. Gate booking on `verified` if the tenant requires it.

---

## 4. Roles & permissions

- **Roles:** `resident/member` (books), `admin/director` (approves, configures, posts, moderates), `superAdmin` (platform owner; creates tenants, manages admins).
- **Client gating:** one `isAdminProvider`. Admin-only affordances (post button, channel delete, settings) are wrapped in `if (isAdmin)`. **This is UX only — never the security boundary.**
- **Firestore rules patterns (the real boundary):**
  - Helper functions: `isSignedIn()`, `isMember(tid)`, `isTenantAdmin(tid)`, `isSuperAdmin()`.
  - Public summary directory: `read: if true`.
  - Sensitive collections (reservations, payments, waitlist, PIN material): **server-write only** (`write: if false`) — only Cloud Functions (Admin SDK) write them; users read their own.
  - Config (resources, settings, channels): read if member, write if tenant admin.
  - Collection-group reads need the recursive-wildcard rule.

---

## 5. Bookable resources + availability

- **Resource model:** `{ type, name, description, photoUrl, status(active|comingSoon|maintenance), slotMinutes, capacity, openHour, closeHour, requiresPin, pricing }`. `capacity > 1` = multiple identical units (e.g. courts) booked in parallel.
- **24-hour resources:** represent "always open" as `openHour 0 / closeHour 24`; the editor has an **"Open 24 hours" toggle** that disables the open/close pickers.
- **Availability is computed server-side, not by reading others' bookings.** Residents can't read other people's reservations (rules deny it), so expose a **callable function `getAvailability`** that returns only **busy intervals** (start/end/unit) — no private data. The client computes free/booked slots from those.
- **Slot picker rules (reusable UX):**
  - Hour grid for the selected day; a horizontal **date strip** rolling forward `advanceBookingDays` from "today" (auto-advances at midnight because it's computed from `now`).
  - **For today, hide past slots.**
  - **Consecutive-hours selection** up to `maxHours` (e.g. 2). Tapping an adjacent slot extends; tapping an end shrinks; tapping a 3rd consecutive shows an **"up to N hours" dialog**; tapping a **non-adjacent** slot **keeps** an existing full block (don't wipe it) and explains, or moves a single pick.
  - Fully-booked hour → greyed "BOOKED" + a **bell to join the waitlist**.
  - A small footer under the last slot ("Lights close at 10:00 PM") derived from `closeHour`.
- **Court/unit assignment:** server assigns the lowest free unit number at booking time.

---

## 6. Booking / checkout / payments

- **Checkout = a full-screen route (no bottom nav)** with an Order Summary that **scrolls** under a **pinned total bar**. Show: line item, unit selector, **Subtotal → Tax → Total**, card-on-file row with **Change**, **Reserve**, and **"Other ways to pay"** → sheet with **Apple Pay / Google Pay**.
- **Tax:** a single rate constant (e.g. 8.25%); `total = subtotal + round(subtotal * rate)`. Compute the same way everywhere (checkout, receipts, refunds).
- **Payment methods on the user:** `paymentMethods: [{id, brand, last4}]` + `selectedCardId`. Display as `Brand •••• last4`. A reusable **payment-methods sheet** (select / add / remove / set default) + Apple Pay row.
- **Server creates the booking** (`createReservation`): enforces weekly-hours cap, max-active reservations, advance-window, payment gate, assigns the unit, mints the PIN+token. Pass `paymentId` (a payment record) and snapshot a **`paymentMethod` label** (e.g. `"Discover •••• 9293"` or `"Apple Pay •••• 9293"`) onto the booking so receipts can show *what it was paid with* even if the card is later removed. Apple/Google Pay should still show the backing card's last 4.
- **Receipts/invoices (reusable component):** a card with `RECEIPT` header, rows for **Subtotal, Tax, Total paid**, a **Refunded** row (accent color) + **Net charged $0.00** for cancellations, a **Paid with** row (method on one line, `•••• 1234` on the next), and a "no payment was charged" variant for free/uncharged bookings. Show this on **both** the upcoming detail and the history detail.
- **Refunds** = full `total` (subtotal + tax), computed server-side; client shows the estimate.
- **Stripe:** scaffold the data model + flow first; keep the real charge/refund behind one `PaymentRepository` so you can swap stub → live without touching screens.

---

## 7. Access control — PIN + QR (the "get-in" logic)

- **Generate at booking:** a one-time **numeric PIN** and a **signed QR/deep-link token**. Store only `pinHash` + `salt` server-side; the raw PIN is returned **once** to the booking device and cached locally (so it survives app restarts).
- **Reveal window:** PIN/QR become visible **N minutes before start** (e.g. 10) and stop at the window end. Before that, show a **locked card** ("Your PIN will show 10 minutes before your reservation starts — at 5:50 PM").
- **Check-in:** within the access window the user taps **Check in**; the server validates PIN/QR (`validateAccess`), marks `checkedIn`, and (later) calls the door **AccessProvider**. The token **expires at the window end**.
- **Door hardware abstraction:** `AccessProvider` interface with a `MockAccessProvider` now; real lock vendor implements the same interface later. The booking flow never knows the vendor.

---

## 8. Booking rules & their enforcement (scheduled + on-write)

All admin-editable on a tenant `settings` object, with **plain-language labels** in the UI grouped into sections (Booking limits / Check-in & no-shows / Cancellations):
- `maxBookingHoursPerWeek`, `advanceBookingDays`, `maxActiveReservationsPerUser`
- `checkInGraceMinutes`, `noShowThreshold`, `noShowBanDays`
- `cancellationCutoffMinutes`, `cancellationAllowance`

**Cancellation logic (reusable rule):** a cancellation **only counts** toward the member's limit if made **at/after the reservation start**; cancelling **before start is free**. The confirm dialog always shows, displays the **full refund amount (with tax) big & bold**, and *when after start* adds a tooltip/note: *"This counts toward your cancellations — you have X left"* (`X = allowance − count`). The confirm dialog should **dismiss immediately** on tap (pop first, run the async cancel after). Don't notify the canceller.

**Scheduled functions (Cloud Scheduler / onSchedule):**
- **Grace sweep:** mark **no-show** if not checked in by `start + checkInGraceMinutes`; bump the member's no-show count; ban for `noShowBanDays` once `noShowThreshold` is hit.
- **Expiry sweep:** expire tokens/bookings past their window.
- **Reminders (every ~5 min):** T-30 "coming up" and at-start "your slot is active" — **each sent once**, guarded by a flag on the booking, and **filtered to `status == booked`** so cancelled bookings never get reminded.
- **Ban expiry:** lift bans when `bannedUntil` passes.

---

## 9. Notifications

- **FCM push** + an **in-app inbox** (`notifications/{id}` per user, unread badge on a bell).
- **Waitlist:** when a fully-booked slot is cancelled, server pings the FIFO waitlist (`notifyWaitlist`) — the *other* residents, not the canceller.
- **Deep links:** notifications carry a route; tapping opens the relevant booking/dialog. (For demo without a real push backend, a local-notification can simulate the deep-link flow.)

---

## 10. Community chat (optional module)

- **Entry:** a floating dark chat **FAB** (with an unread dot) on the main content tabs → opens a full-screen **"Community Chat"** modal with **Channels | DMs** tabs anchored to the bottom.
- **Channels:** `tenants/{tid}/channels/{cid}` + `messages` subcollection. A **General** channel; **admins create channels**. Channel view = date-divided message bubbles + composer. **Delete** uses a **type-to-confirm** dialog ("type `DELETE GENERAL`"); the General channel is protected.
- **DMs / groups:** `tenants/{tid}/dms/{id}` with `participantIds[]` (`arrayContains` current uid to stream a user's threads), `isGroup`, `lastText/lastAt`. A **+ → member-multi-select** (only enrolled members) starts a 1:1 or group thread (dedupe by exact participant set).
- **Rules:** channel read = member, write = admin; messages create if member && `senderId == auth.uid`; DM access gated on `auth.uid in participantIds`.

---

## 11. Admin

- **Layout = a clean rows list** (colored icon square + label + chevron + dividers), not a grid of cards.
- **Sections:** Residency approvals, Resources/Amenities manager (CRUD + 24h toggle + pricing + status), Reports, **Booking rules** (the settings above, nicely grouped), Members. (We removed a redundant "Reservations" calendar and the per-tenant "Branding" editor — add back only if needed.)
- **Editors are modal bottom sheets** with an X + discard-confirm; **must use `useRootNavigator: true`** so they render above the floating bottom nav (otherwise the Save button hides behind it).

---

## 12. Events / announcements

- A feed on the home tab; **admins get a `+`** ("Add Event or Announcement"). The compose sheet has a **type chooser (Announcement | Event)** → **Title** + **Description**; the list icon reflects the type (megaphone vs calendar). Admins can swipe-to-delete with a confirm.

---

## 13. Design system & reusable UI patterns

- **One fixed dark theme:** near-black canvas, white text, a single bright accent (we used electric lime `#C8FA4B`). Define tokens (`lime`, `onLime`, `surface1`, `surface2`, `muted`, `outline`) in one `AppTheme`. Theme: buttons, cards, dialogs, bottom sheets, inputs, dividers, **snackbars**.
- **Floating animated bottom nav:** a rounded pill with an accent highlight that **slides** to the selected tab; admin tab only for admins. Body does **not** extend under it (`extendBody: false`) so screen content / action bars / FABs clear it.
- **Modals above the floating nav:** any `showModalBottomSheet` with bottom actions → `useRootNavigator: true`.
- **Snackbars (toasts):** route everything through one `showSnack(context, msg)` helper that **`hideCurrentSnackBar()` before showing** — so spamming an action shows one toast, not a stack. Theme them dark + floating; keep the bottom inset small (floating already lifts above nav/FAB — a big inset shoves it to mid-screen).
- **AlertDialog action buttons:** to get two equal-width buttons, wrap them in a **`Row` inside `actions`** — putting `Expanded` directly in `actions` (an OverflowBar) throws a layout error and renders a broken/white dialog. (This bug bit us in 4 places.)
- **Confirm dialogs** are modal (can't stack); prefer a dialog over a toast for "limit reached" messages.
- **Detail = a dialog, not a page**, when it's a quick look (reservation detail, etc.); header is a generic title ("Reservation") + X, and the body card carries the specific name — **avoid showing the same name twice**.
- **Lists → tappable cards** that open the detail dialog; show a small **"View details ›"** affordance as plain text (not a button, so it doesn't get its own hover/highlight when the whole row is the tap target). Status labels color-coded (green Completed, muted Cancelled, red No-show).
- **Formatting helpers (shared):** `formatPhone` + a live `PhoneInputFormatter` → `(123) 456-7890`; `addressTwoLine` → street on line 1, "City ST ZIP" on line 2 (split at first comma), with unit shown separately or "—".
- **Image thumbnails:** use real photos as resource thumbnails where you have them, with an icon fallback.

---

## 14. Web deployment & emulator gotchas (these cost real time — keep them)

- **Use `127.0.0.1`, not `localhost`,** for emulator hosts on web (localhost can resolve to IPv6 `::1` and silently fall back to production auth). Call `useAuthEmulator(...)` **before** `runApp`.
- **Don't set `authDomain`** in demo Firebase options on web (it triggers the auth-handler that routes to production).
- **Firebase Auth web persistence race:** the SDK restores the session from the `firebaseLocalStorageDb` IndexedDB on reload and can race the emulator binding → auth hits production. **Delete that IndexedDB in `index.html` before booting** for deterministic emulator login.
- **Stale builds / "my changes aren't showing":** the **Flutter service worker** caches the old bundle and serves it even with no-cache headers. Build with **`--pwa-strategy=none`**, ship a **self-destructing `flutter_service_worker.js` "kill switch"** (clears caches + unregisters + reloads), unregister SWs in `index.html`, and serve with a **no-cache static server**. Even then a browser may need **one** Incognito load / "Clear site data" to drop the old worker.
- **Hide the Firebase emulator warning banner** (it covers the bottom nav): CSS `.firebase-emulator-warning { display:none !important }`.
- **Mobile-on-desktop:** constrain the app to a phone width (e.g. `maxWidth 480`) in `MaterialApp.builder`; left-align on wide screens.
- **CanvasKit + automated testing:** semantic `.click()` may not trigger Flutter gestures — use coordinate-based mouse clicks; enable accessibility to read element rects.

---

## 15. Cloud Functions inventory (typical set)

Callable: `getAvailability`, `createReservation`, `validateAccess`, `cancelReservation`, `createPayment`.
Scheduled: `reminders`, `graceSweep`, `expirySweep`, `banExpiry`.
Each enforces auth + tenant membership, does its writes with the Admin SDK, and returns the minimal data the client needs (e.g. cancel returns `{ counted, cancellationCount, allowance, refundCents }`).

---

## 16. Seeding & demo data

A `seed` script (Admin SDK against the emulator) that creates: 1–2 tenants (to prove multi-tenancy), an admin + a couple residents (with demo phone/address/payment methods), the resources, some announcements (one `event`, one `announcement`), and **sample reservations covering every state** — upcoming (with a `paymentMethod` snapshot), completed-paid, and cancelled-refunded — so every screen and the receipt variants look real out of the box. Use **fixed doc ids + `.set()`** so re-seeding is idempotent; clear stale docs first.

---

## 17. Build order (phased — stop at each ⛳ and confirm)

1. **Scaffold:** stack, folders, theme tokens, emulator wiring, multi-tenant providers. ⛳
2. **Auth & onboarding:** tabbed login/signup, tenant-first signup, forgot-password, residency, router gating. ⛳
3. **Tenancy & roles:** directory, memberships, Firestore rules + helpers, admin gating. ⛳
4. **Resources & availability:** resource CRUD, `getAvailability`, slot picker. ⛳
5. **Booking & payments:** checkout, money/tax, payment methods, `createReservation`, receipts. ⛳
6. **Access:** PIN/QR generate + reveal window + `validateAccess` + AccessProvider mock. ⛳
7. **Rules & schedulers:** cancellation counting, no-show/ban, reminders, sweeps. ⛳
8. **Notifications, chat, events, admin dashboards.** ⛳
9. **Polish:** floating nav, dialogs, snackbars, formatting, empty states, animations. ⛳
10. **Web deploy hardening:** SW kill-switch, no-cache server, emulator gotchas. ⛳

---

## 18. Hard-won rules to not relearn (the cheat sheet)

- Server enforces rules; client only displays. Sensitive collections are server-write only.
- Tenant-scope everything; load branding/flags at runtime; collection-group needs the wildcard rule.
- Public directory must be **public-read** so pre-auth signup can list tenants.
- Money in cents; one tax rate; one `Money` formatter; refunds = total (incl. tax).
- PIN hashed only; revealed N-min-before; tokens expire at window end.
- Cancellation counts only **after start**; confirm dialog dismisses immediately; canceller isn't notified.
- Reminders filtered to `booked` + once-only flags.
- `Expanded` goes in a `Row` inside `AlertDialog.actions`, never directly.
- One `showSnack` helper that replaces the current toast; theme toasts dark; small bottom inset.
- Modal sheets with actions → `useRootNavigator: true` so they clear the floating nav.
- Web: `127.0.0.1`; clear the Firebase IndexedDB pre-boot; `--pwa-strategy=none` + SW kill-switch + no-cache server; expect one manual cache-clear per browser.

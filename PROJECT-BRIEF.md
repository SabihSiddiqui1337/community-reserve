# PROJECT BRIEF — Community Amenity Reservation Platform (Flutter)

> **How to use this file:** Paste this whole document into Claude Code as the opening prompt. It is both the spec and the working instructions. Build in the phases listed at the bottom. Pause at the ⛳ checkpoints and ask me before moving on.

---

## 0. What we're building (one paragraph)

A **white-label mobile app** that lets residents of a community (HOA) **reserve shared amenities** — pickleball courts (live now), a gym (coming soon), and a community hall — and get a **temporary PIN + QR code** that only works during their reserved time window. The first customer is a friend's HOA, but the platform must be **generic and reusable across many communities** from day one (multi-tenant), with each community able to set its own branding (logo, colors, background) and its own booking rules. Build it beautiful: dark mode, modern, animated, mobile-first.

**Working codename:** `CommunityReserve` (rename freely).

---

## 1. Tech stack (use this — it's decided)

- **Mobile:** Flutter (iOS + Android), Dart, **Riverpod** for state management, **go_router** for navigation.
- **Backend:** **Firebase**
  - Auth (email/password to start; phone + social later)
  - Firestore (data)
  - Cloud Storage (residency-verification document uploads)
  - **Cloud Functions (TypeScript)** for all business-rule enforcement
  - **Cloud Scheduler / scheduled functions** for the time-based jobs (grace sweep, expiry, reminders)
  - **FCM** for push notifications
- **Payments:** **Stripe** (`flutter_stripe`) — supports Apple Pay, Google Pay, and cards. **Scaffold only** in MVP (data model + stubbed flow), real integration later.
- **QR:** `qr_flutter` (generate), `mobile_scanner` (scan, for admin/kiosk).
- **Door hardware:** Out of scope for code now — build an **abstraction layer** only (see §8). I'll wire a real lock vendor later.

> Alternative noted for the record: Supabase (Postgres + RLS) is also viable and arguably cleaner for multi-tenant isolation, but we're going Firebase for speed, first-class push, and the scheduled-function story. Don't switch unless I say so.

**Critical architectural rule:** This is **multi-tenant**. Every record is scoped by `communityId`. Branding and feature flags load per community at runtime and drive the theme. Never hardcode anything community-specific.

---

## 2. Roles

- **Resident** — books amenities, manages their reservations.
- **Community Admin / Director** — approves residency, configures amenities & rules, oversees reservations, edits branding, runs reports. (This is my HOA friend.)
- **Super Admin** — platform owner (me). Creates communities, manages admins across all tenants.

---

## 3. Data model (Firestore collections)

Use this as the source of truth. Sub-collections where it makes sense.

**`communities/{communityId}`**
- `name`, `address`, `timezone`
- `branding`: `{ logoUrl, primaryColor, accentColor, backgroundUrl, theme }`
- `settings` (defaults, all admin-editable — see §6 for what these control):
  - `maxBookingHoursPerWeek` (default 3)
  - `advanceBookingDays` (default 7)
  - `maxActiveReservationsPerUser` (default 2)
  - `checkInGraceMinutes` (default 15)
  - `noShowThreshold` (default 3)
  - `noShowBanDays` (default 30)
  - `cancellationCutoffMinutes` (default 60)
- `featureFlags`: `{ paymentsEnabled, gymEnabled, ... }`

**`users/{userId}`** — `name`, `email`, `phone`, `photoUrl`, `fcmTokens[]`, `globalRole` (resident | superAdmin)

**`communities/{communityId}/memberships/{userId}`**
- `role` (resident | admin)
- `residencyStatus` (pending | verified | rejected)
- `verificationDocUrl`, `unit`/`household`, `reviewedBy`, `reviewedAt`, `rejectionReason`
- `noShowCount` (rolling), `bannedUntil` (timestamp | null)

**`communities/{communityId}/amenities/{amenityId}`**
- `type` (pickleballCourt | gym | hall | generic)
- `name`, `description`, `photoUrl`
- `status` (active | comingSoon | maintenance)
- `openHours` (per weekday), `slotMinutes` (e.g. 60), `bufferMinutes`
- `capacity` (e.g. number of courts/lanes), `requiresPin` (bool)
- `pricing`: `{ isPaid, amountCents, currency, depositCents }`
- `bookingRules` (optional per-amenity overrides of community settings)

**`communities/{communityId}/reservations/{reservationId}`**
- `amenityId`, `userId`
- `startTime`, `endTime`, `status` (booked | checkedIn | completed | noShow | cancelled | expired)
- `pinHash` (never store raw PIN), `qrToken` (signed), `accessCredentialId` (for future lock vendor)
- `checkedInAt`, `createdAt`, `cancelledAt`
- `paymentId` (nullable)

**`communities/{communityId}/waitlist/{waitlistId}`**
- `amenityId`, `userId`, `desiredStart`, `desiredEnd`, `status` (waiting | notified | fulfilled | expired)

**`communities/{communityId}/payments/{paymentId}`** (scaffold)
- `userId`, `reservationId`, `amountCents`, `currency`, `status` (pending | succeeded | refunded | failed), `provider` (stripe), `providerRef`

**`communities/{communityId}/notifications/{notificationId}`** — in-app inbox mirror of pushes.

---

## 4. Core business rules (ENFORCE SERVER-SIDE in Cloud Functions — never trust the client)

### 4.1 Booking
- Resident must have `residencyStatus == verified` and not be banned (`bannedUntil` null or past).
- Reject if it would exceed `maxBookingHoursPerWeek`, `maxActiveReservationsPerUser`, or the `advanceBookingDays` window.
- Reject double-booking of the same slot beyond `capacity`.
- Reject if amenity `status != active`.
- If amenity `isPaid` and payments enabled → require a (stubbed) successful payment before confirming.

### 4.2 Temporary PIN + QR
- On confirm, generate a cryptographically random **6-digit PIN** and a **signed QR token** (JWT-style, payload = reservationId, `exp` = window end). Store **pinHash** only.
- PIN/QR are **valid only within `[startTime, endTime]`** (optionally a small few-minute pre-buffer). A validation endpoint checks: status is booked/checkedIn, now is inside the window, reservation not released. **After `endTime`, the PIN/QR must fail** ("door won't open").
- First successful PIN/QR validation = **check-in**: set `checkedInAt`, status → `checkedIn`, and **cancel the grace timer**.

### 4.3 Check-in grace (the 15-minute rule)
- Scheduled **grace-sweep function (runs every minute)**: find reservations where `now > startTime + checkInGraceMinutes` AND status is still `booked` (never checked in).
- For each: status → `noShow`, **free the slot**, increment that member's `noShowCount`, and trigger waitlist notifications for that amenity/window.

### 4.4 No-show penalty
- When `noShowCount` reaches `noShowThreshold` (default 3): set `bannedUntil = now + noShowBanDays` (default 30) and reset the counter. Send a notification explaining the ban. All values admin-configurable.

### 4.5 Waitlist / "notify me when it opens"
- If a slot is full, a resident can join the waitlist for that amenity/window.
- When a slot is released (no-show auto-release OR a cancellation), find matching waitlist entries (FIFO), send a **push**: "A slot you wanted just opened." First to re-book wins; don't auto-assign.

### 4.6 Cancellation
- Free cancellation up to `cancellationCutoffMinutes` before start. Later cancellations may count toward no-show (make this a setting; default: late cancel = counts as no-show).

---

## 5. Scheduled / background jobs (Cloud Scheduler functions)

1. **Grace sweep** (every 1 min) — §4.3.
2. **Expiry sweep** (every 5 min) — mark past-`endTime` reservations `completed`; invalidate credentials.
3. **Reminders** — push before start (e.g. T-30 min) and a "your slot is active, here's your PIN" at start.
4. **Ban expiry** — clear `bannedUntil` when elapsed.

---

## 6. Admin-configurable settings (must be editable in the admin UI)

Per community (with optional per-amenity overrides): weekly hour cap, advance-booking window, max active reservations, check-in grace minutes, no-show threshold, ban duration, cancellation cutoff, slot length, open hours, capacity, paid/free + price, feature flags. **Nothing in this list should be hardcoded** — read it from `community.settings`.

---

## 7. Screens (build all; make the booking flow especially clean)

**Onboarding/Auth:** splash → sign in / sign up → **join your community** → residency verification → "pending review" state.

**Community-join step (make this polished — it's the first impression):**
- One clean screen, two ways to find a community: **search by name** or **enter a join code**.
- **Live auto-detect:** as the user types the code (or taps a search result), the screen instantly resolves it and shows a confirmation card — community **logo + "Community: [Name]" + city** — so they confirm before committing.
- **Continue** stays disabled until a valid community is detected. Unknown/invalid code → gentle inline hint, never a hard error.
- Smooth & convenient: debounced lookup, subtle animation when the community card slides in, autofocus, paste-friendly code field, recent/nearby suggestions if available.
- After Continue → residency verification (upload bill / driver's license / ID) → "pending review" until an admin approves.

**Resident app:**
- **Home** — community branding header, my upcoming reservations, quick-book CTA, standing/no-show status if relevant.
- **Amenities** — list with status badges (Live / Coming Soon / Maintenance); detail screen shows hours, rules, price.
- **Booking flow** — day view → available slot picker → confirm → (payment if paid) → success.
- **Reservation detail** — live countdown, **PIN revealed only while active**, QR code, check-in button, cancel, add-to-calendar.
- **Waitlist** — my "notify me" requests.
- **Inbox** — notifications history.
- **Profile** — info, residency status, payment methods (stub), standing.

**Admin:**
- Approvals queue (residency docs → approve/reject).
- Amenities manager (CRUD + all settings in §6).
- Reservations calendar (view, manual cancel/override).
- Reports (no-shows, utilization).
- Branding editor (logo, colors, background → live theme).
- Members list.

---

## 8. Door hardware — abstraction only (no real integration yet)

Define an `AccessProvider` interface in the backend with: `provisionCredential(reservation)` and `revokeCredential(reservation)`. MVP ships a `MockAccessProvider` (logs only). The reservation already carries `pinHash` / `qrToken` / `accessCredentialId` so a real vendor can plug in later. **Guidance for me (not for code now):** for gated courts/doors, plan around commercial access control with a developer API (e.g. **Kisi** or **Brivo** — cloud-managed, QR + PIN, good APIs) or **Igloohome** keypads (generate **offline, time-bound PINs algorithmically** — a strong fit since our PINs are already window-bound and it needs no connectivity at the door). Integration pattern: backend provisions a time-bound credential on booking confirm and revokes it on release/expiry. *(Verify current vendor API docs before buying.)*

---

## 9. Design direction

Dark mode first (offer light too), modern and premium, smooth micro-animations and page transitions, large tappable targets, mobile-first. The theme must be **driven by each community's branding** so the same app reskins per tenant. Seed a demo community so screens look real out of the box.

---

## 10. Quality & structure

- Feature-first folder structure, clean separation (data / domain / presentation).
- All money/time math in a shared layer; everything timezone-aware (use the community's timezone).
- Firestore security rules enforcing tenant isolation + role checks.
- Seed script: one demo community with pickleball (active), gym (comingSoon), hall (active), a couple of demo users (1 admin, 2 residents), and sample reservations.
- README + ARCHITECTURE.md + a CLAUDE.md capturing conventions.

---

## 11. Build phases (do them in order; ⛳ = stop and check with me)

- **Phase 0 — Scaffold:** Flutter app + Firebase project wiring + folder structure + theming/white-label foundation + seed data. ⛳
- **Phase 1 — Auth, multi-tenant theming, residency verification** (upload + admin approve/reject). ⛳
- **Phase 2 — Amenities + booking + availability** (with weekly quota, advance-window, capacity rules). ⛳
- **Phase 3 — PIN + QR, check-in, 15-min grace sweep, no-show penalty.** ⛳
- **Phase 4 — Waitlist + FCM notifications + reminders.** ⛳
- **Phase 5 — Payments scaffold (Stripe, stubbed).**
- **Phase 6 — Admin dashboard (approvals, amenity config, reports, branding editor).** ⛳
- **Phase 7 — Polish: animations, empty states, error handling, demo seed for showcasing.**

Door hardware stays an abstraction (§8) until I say otherwise.

---

## 12. Start here

1. Confirm the stack in §1 and propose the exact folder structure + package list.
2. Scaffold Phase 0.
3. Then stop at the ⛳ and wait for my go-ahead.

# Embedded Resident-Portal WebView (the "HOA" tab)

> **What it is:** a thin, embedded WebView tab that loads a community's
> **existing** resident portal (e.g. ResMan / MyResMan) inside the app. There is
> **no API integration, no scraping, and no data storage** — the portal owns
> auth, payments, statements, and work orders. We just host it in a themed
> browser tab and keep the session alive across launches.

---

## 1. Why this exists

Many communities already run a third-party resident portal (ResMan, AppFolio,
etc.) that handles rent payments, statements, and maintenance requests. Building
a native equivalent would mean integrating each vendor's API — and, worse,
handling financial data ourselves (PCI scope, statement storage, refunds).

Embedding the portal's own web UI sidesteps all of that:

- **No API access required.** Works with any portal that has a mobile web UI.
- **We never touch financial data.** Rent payments redirect to the portal's own
  processor; the app just hosts the page.
- **Per-tenant, zero-code onboarding.** Point a community at its portal URL and
  the tab lights up — see §5.

It is deliberately **thin**: no credentials stored, no page data cached by us,
no scraping. If a community has no portal, the tab is hidden.

---

## 2. Per-community config (`residentPortalUrl`)

The single config field lives on the `Community` model
(`lib/features/community/domain/community.dart`):

```dart
// URL of the community's existing resident portal (e.g. ResMan). When set,
// the "HOA" tab loads it in an embedded WebView; when null, the tab hides.
String? residentPortalUrl,
```

- Read at runtime via `ref.watch(activeCommunityProvider).residentPortalUrl`
  (provider in `lib/features/community/application/tenant_providers.dart`).
- **Hide-the-tab rule:** when `residentPortalUrl` is `null`/empty, the HOA tab is
  not shown (nav wiring owns this). The screen itself still renders a safe
  "Resident portal not configured" placeholder as a belt-and-braces fallback.
- Demo seed value: `https://southside.myresman.com`.

Nothing portal-specific is hardcoded — the URL is read per tenant, consistent
with the multi-tenant non-negotiables in `CLAUDE.md`.

---

## 3. Implementation

- **Screen:** `lib/features/hoa/presentation/hoa_portal_screen.dart` —
  `class HoaPortalScreen extends ConsumerStatefulWidget` (`const` ctor).
- **Package:** `flutter_inappwebview` (`InAppWebView`), plus `url_launcher` for
  external-browser fallbacks.
- **Chrome:** themed `AppBar` (community name as title, `centerTitle` from theme)
  with an overflow `PopupMenuButton`:
  - **Log out of portal** — clears cookies + web storage for the site.
  - **Open in browser** — launches `residentPortalUrl` via `url_launcher`.
  - Spinner / error state styled to the dark theme with `AppTheme.lime` accents.
  The web content itself is untouched.

### Key behaviours

- **Cookie / session persistence.** We do **not** clear cache or cookies on
  `dispose` — the resident stays logged in across launches. The *only* sign-out
  path is the explicit "Log out of portal" menu item, which calls
  `CookieManager.deleteAllCookies()` + `WebStorageManager.deleteAllData()` and
  reloads.
- **Payment-redirect handling.** `shouldOverrideUrlLoading` returns
  `NavigationActionPolicy.ALLOW` for **every** domain — rent-payment flows
  redirect to third-party processors and must not be blocked. New windows
  (`target=_blank` / `window.open`) are handled in `onCreateWindow` by loading
  the URL **in the same webview** so the authenticated session carries.
- **Loading.** A themed `LinearProgressIndicator` driven by `onProgressChanged`
  / `onLoadStart` / `onLoadStop`, plus **pull-to-refresh** via
  `PullToRefreshController` (mobile only; guarded off web/desktop).
- **Back navigation.** Wrapped in `PopScope(canPop: false)`; system/app back
  calls `webView.canGoBack()` → `goBack()` first and only pops the route when
  there is no webview history left.
- **Downloads.** `onDownloadStartRequest` (`useOnDownloadStart: true`) lets
  PDFs/statements download. On mobile the platform handles it natively; on
  web/desktop we fall back to opening the file URL via `url_launcher`.
- **Uploads (camera + gallery).** Work through the native picker by default.
  Settings enable them: `allowFileAccess`, `allowContentAccess`,
  `javaScriptCanOpenWindowsAutomatically`. iOS inline media is allowed
  (`allowsInlineMediaPlayback`). Needs the platform permissions in §4.
- **Error / offline.** `onReceivedError` / `onReceivedHttpError` for the **main
  frame** show a graceful error state with **Retry** (reload) and **Open in
  browser** fallback. Sub-resource failures (ads/trackers) are ignored.
- **User-Agent fallback.** `InAppWebViewSettings.userAgent` is set to a standard
  mobile-browser UA (Chrome on Android) so portals that mis-render under the
  default WebView UA still work.

We **do not** store credentials, scrape pages, or cache page data.

---

## 4. Platform setup

### Android (`android/app/`)

- **`build.gradle.kts`** — `minSdk` floored to **21** (Android 5.0), the
  `flutter_inappwebview` minimum: `minSdk = maxOf(21, flutter.minSdkVersion)`.
- **`AndroidManifest.xml`** — permissions: `INTERNET`, `CAMERA`, and (for
  pre-API-33 file picking) `READ_EXTERNAL_STORAGE` (`maxSdkVersion=32`) plus
  `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` for API 33+.
- **`FileProvider`** — an `androidx.core.content.FileProvider` entry with
  authority `${applicationId}.flutter_inappwebview.fileprovider`, backed by
  `res/xml/provider_paths.xml`, so the WebView can hand camera/file uploads to
  the portal.

### iOS (`ios/Runner/Info.plist`)

- `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` (resident
  work-order photo uploads). Strings cover both profile photos and portal
  attachments.

---

## 5. Enabling it for a new tenant

1. Set `residentPortalUrl` on the community document (Firestore
   `communities/{communityId}.residentPortalUrl`) to the portal's mobile URL,
   e.g. `https://yourcommunity.myresman.com`.
2. That's it — the HOA tab appears and loads the portal. Unset (or empty) the
   field to hide the tab again.

No code changes, no per-tenant builds. The field is the entire switch.

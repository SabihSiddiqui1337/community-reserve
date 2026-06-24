# App Store (and Play Store) path

The backend is already live and shared — the iOS/Android app will use the **same
Firebase** (`amenry-prod`) as the web app, so all data/logins carry over. This is
purely about packaging the existing Flutter app as a native app and submitting it.

## What only YOU can procure (hard blockers)

1. **A Mac with Xcode.** iOS apps can only be built/signed/submitted from macOS.
   - No Mac? A cloud Mac works: **MacinCloud** or **AWS EC2 mac** (rent by the hour).
2. **Apple Developer Program — $99/year.** https://developer.apple.com/programs/
   - Required to sign the app and submit to TestFlight / the App Store.
3. **(Android, optional) Google Play Console — $25 one-time.**

## What CLAUDE does once you have the above

1. `flutterfire configure --platforms=ios` (and `android`) — registers the iOS app
   in Firebase + adds `GoogleService-Info.plist`. *(Held off until now so it can't
   disturb the live web config.)*
2. App identity: bundle id (e.g. `app.amenry.mobile`), display name, version.
3. **App icons + splash** from the lime brand (one command via `flutter_launcher_icons`).
4. **Push notifications (APNs):** upload the APNs key to Firebase, wire the
   entitlement — the app already has FCM code.
5. Build: `flutter build ipa` → open in Xcode → set signing to your Apple team.
6. **TestFlight** first (internal testing on your phone), then submit for review.
7. App Store listing copy, screenshots, privacy questionnaire.
8. Android: `flutter build appbundle` → Play Console internal track → production.

## Realistic timeline

- Procure Mac access + Apple account: ~1 day (mostly Apple's verification).
- Config → first TestFlight build on your phone: ~half a day of our work.
- Apple review: typically 1–3 days.

When you've got the Mac + Apple account, just say so and we start at step 1.

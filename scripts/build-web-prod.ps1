# Build the Flutter web app for PRODUCTION — talks to the REAL Firebase backend
# (USE_EMULATORS=false), not the local emulators. Use this before
# `firebase deploy --only hosting`. See GO-LIVE.md.
#
# `--pwa-strategy=none` makes Flutter emit an EMPTY flutter_service_worker.js,
# which overwrites our kill switch, so we copy it back after the build (avoids
# stale-cache issues for users on their phones).
Set-Location (Join-Path $PSScriptRoot "..")
flutter build web --release --pwa-strategy=none --dart-define=USE_EMULATORS=false
Copy-Item "web\flutter_service_worker.js" "build\web\flutter_service_worker.js" -Force
Write-Host "Production web build complete (USE_EMULATORS=false) -> build/web"

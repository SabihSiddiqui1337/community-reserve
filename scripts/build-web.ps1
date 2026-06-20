# Build the Flutter web app and re-apply the service-worker kill switch.
# `--pwa-strategy=none` makes Flutter emit an EMPTY flutter_service_worker.js,
# which overwrites our kill switch, so we copy it back after the build.
Set-Location (Join-Path $PSScriptRoot "..")
flutter build web --pwa-strategy=none
Copy-Item "web\flutter_service_worker.js" "build\web\flutter_service_worker.js" -Force
Write-Host "Build complete; kill-switch service worker re-applied."

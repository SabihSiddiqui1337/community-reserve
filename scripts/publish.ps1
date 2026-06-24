# Publish the app to LIVE (https://amenry-prod.web.app).
#
#   scripts/publish.ps1          -> builds the prod web app + deploys Hosting
#                                   (the usual case for UI / Dart changes)
#   scripts/publish.ps1 -Full    -> ALSO deploys Functions + rules + indexes + storage
#                                   (use when you changed functions/ or the *.rules files)
#
# Local development is untouched — this only writes to the live site.
param([switch]$Full)

Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "==> Building production web app..." -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File scripts/build-web-prod.ps1

if ($Full) {
  Write-Host "==> Deploying EVERYTHING (hosting + functions + rules)..." -ForegroundColor Cyan
  firebase deploy --project amenry-prod
} else {
  Write-Host "==> Deploying hosting..." -ForegroundColor Cyan
  firebase deploy --only hosting --project amenry-prod
}

Write-Host "`nPublished -> https://amenry-prod.web.app" -ForegroundColor Green

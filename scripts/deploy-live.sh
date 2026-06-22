#!/usr/bin/env bash
# Deploy the Amenry backend to a REAL Firebase project so the app works off
# your Wi-Fi (login, bookings, check-in, Cloud Functions all reachable from the
# internet instead of only the emulators on your Mac).
#
# Run the interactive PREREQ steps below ONCE first, then this script deploys.
#
#   PREREQ 1 — log in (opens a browser):
#       npx -y firebase-tools login
#
#   PREREQ 2 — point the repo at your real project (replace the id), and make
#   sure it's on the Blaze plan (Cloud Functions v2 require pay-as-you-go):
#       npx -y firebase-tools projects:create amenry-prod   # or use an existing one
#       npx -y firebase-tools use amenry-prod
#
#   PREREQ 3 — write the real firebase_options.dart for the apps:
#       export PATH="$PATH:$HOME/.pub-cache/bin"
#       flutterfire configure --project=amenry-prod
#
# Then run:  bash scripts/deploy-live.sh
set -euo pipefail
cd "$(dirname "$0")/.."

FB() { npx -y firebase-tools "$@"; }

echo "▸ Active project:"
FB use

echo "▸ Building Cloud Functions…"
( cd functions && npm run build )

echo "▸ Deploying functions + Firestore rules/indexes + Storage rules…"
FB deploy --only functions,firestore:rules,firestore:indexes,storage

echo
echo "✅ Backend is live. Now build the app against the REAL backend (no emulator):"
echo "   flutter run --release -d <iphone-id> --dart-define=USE_EMULATORS=false"
echo "   (the iPhone must be connected/on the same network to install)"

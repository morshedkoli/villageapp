#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${1:-}"
PLATFORMS="${2:-android,ios,web}"

if [[ -z "$PROJECT_ID" ]]; then
  echo "Usage: ./scripts/setup_firebase.sh <firebase-project-id> [platforms]"
  echo "Example: ./scripts/setup_firebase.sh village-dev-123 android,ios,web"
  exit 1
fi

if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
  echo "Set GOOGLE_APPLICATION_CREDENTIALS to your Firebase service account json file."
  echo "Example: export GOOGLE_APPLICATION_CREDENTIALS=\"$HOME/keys/firebase-admin.json\""
  exit 1
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "Installing Firebase CLI..."
  npm install -g firebase-tools
fi

if ! command -v flutterfire >/dev/null 2>&1; then
  echo "Installing FlutterFire CLI..."
  dart pub global activate flutterfire_cli
fi

echo "Verifying Firebase access..."
firebase projects:list >/dev/null

echo "Configuring FlutterFire for project: $PROJECT_ID"
flutterfire configure \
  --project "$PROJECT_ID" \
  --platforms "$PLATFORMS" \
  --yes

echo "Deploying Firestore and Storage rules..."
firebase deploy --only firestore:rules,storage --project "$PROJECT_ID"

echo "Done. Firebase setup completed for $PROJECT_ID"

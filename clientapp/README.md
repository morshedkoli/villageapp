# Village Development Platform

Mobile app built with Flutter + Firebase to make village fund usage transparent and participatory.

## Features

- Public transparency dashboard (no login required)
- Village fund overview with donation history and growth chart
- Donation flow with email-link OTP login and payment method selection
- Public village problem board with status tracking
- Problem reporting with photo upload and location (login required)
- Development projects list with detail view, updates, photos, and spending report
- Citizens directory with search
- Top donor leaderboard (all-time and monthly)
- Profile for logged-in users (donations + reported problems)

## Tech Stack

- Flutter (frontend)
- Firebase Authentication (Email link OTP)
- Cloud Firestore
- Firebase Storage (problem photos)

## Firebase Collections

- `villages`
- `users`
- `donations`
- `fund_transactions`
- `projects`
- `problems`

## Quick Setup

1. Install Flutter and Firebase CLI.
2. Create a Firebase project.
3. Run FlutterFire configure:

```bash
flutterfire configure
```

4. Enable Firebase services:
   - Authentication > Email link sign-in
   - Firestore
   - Storage
5. Deploy rules:

```bash
firebase deploy --only firestore:rules,storage
```

6. Run the app:

```bash
flutter run
```

## Automatic Firebase Setup (No Browser Login)

Use a Firebase service account key to run setup in a CI/non-interactive way.

1. Create a service account key in Firebase Console > Project Settings > Service Accounts.
2. Set env var to the downloaded JSON key path.
3. Run one script:

PowerShell:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\keys\firebase-admin.json"
./scripts/setup_firebase.ps1 -ProjectId "your-project-id"
```

Bash:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/keys/firebase-admin.json"
./scripts/setup_firebase.sh your-project-id
```

This installs `firebase-tools` and `flutterfire_cli` if missing, configures FlutterFire, and deploys Firestore/Storage rules.

## Notes

- Public read access is intentionally enabled by rules for transparency.
- Writes to sensitive/admin data are restricted to admin claims.

## Visual QA Checklist (Release)

- Home dashboard: summary cards, horizontal lists, skeleton loading states
- Village Fund: fund progress card, chart rendering, donation timeline readability
- Projects: status badges, progress bars, detail banner and timeline cards
- Problems: filter chips (`All`, `Pending`, `Approved`, `Completed`) and card media layout
- Citizens: search behavior, avatar cards, empty-state handling
- Leaderboard: top 3 donor highlight cards and ranked list alignment
- Profile: large text toggle, high contrast toggle, donation/problem history sections
- Accessibility: button tap targets, text scaling, contrast in status badges and labels
- Responsiveness: check small phones, medium phones, and web/chrome layout stability

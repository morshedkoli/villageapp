# Native Android App (গ্রামবাসী / GramBasee) — Design Spec

## Purpose

Rebuild the villager-facing `clientapp` (currently Flutter) as a fully
native Android app using Kotlin + Jetpack Compose, with feature parity,
sharing the existing Firebase backend used by `clientapp` and the
`admin` Next.js panel. Reason: native performance/UX and to have a
first-party Android codebase alongside the cross-platform Flutter app.

## Scope

Full parity with `clientapp`'s feature set:

- Splash / onboarding
- Auth: phone+password sign-in, Google sign-in, email+password sign-in
- Home dashboard: village overview (fund collected, spent, balance,
  citizen count), recent donations, recent expenses
- Donations: list, all-donations view, donation checkout (submit a
  donation with transaction ID / sender number / payment method)
- Expenses: all-expenses view (fund_transactions, read-only)
- Problems: list, details, report new problem, upvote/downvote
- Projects: list, details
- Citizens: directory, citizen profile
- Leaders screen
- Notifications (with per-user read tracking)
- Reports screen
- Profile / Settings

Out of scope for this spec: any backend/Firestore schema or rules
changes, admin-side native app, iOS.

## Architecture

- **Project location:** new top-level directory
  `D:\village-admin\villageapp\android-native\` — a separate Gradle
  project, sibling to `admin/` and `clientapp/`, not nested inside
  either.
- **Language/UI:** Kotlin, Jetpack Compose, Material 3 components as
  the component library, with a custom `ColorScheme`/`Shapes`/
  `Typography` seeded from the existing GramBasee design tokens
  (primary `#22C55E`, light/dark themes, the spacing/radius scale
  documented in `clientapp/DESIGN_SYSTEM.md`) so the native app looks
  like the same product, not default Material.
- **Pattern:** MVVM. Compose screens observe `StateFlow`/`Flow` exposed
  by per-feature `ViewModel`s; ViewModels call `Repository` classes;
  repositories wrap Firebase SDKs (Auth, Firestore, Cloud Messaging).
  No other backend — Firestore is read/written directly from the
  client, matching `clientapp`'s architecture.
- **DI:** Hilt for constructor injection of repositories/ViewModels.
- **Navigation:** Compose Navigation. Bottom nav with 5 tabs mirroring
  `clientapp`'s `PremiumBottomNav` (Home, Donations, Problems,
  Citizens, Profile); Projects/Leaders/Reports/Notifications/Settings
  reached via top-level nav or from Home/Profile, matching clientapp's
  existing IA — no new IA decisions needed, follow clientapp's nav
  graph screen-for-screen.

## Backend / Data

- **Same Firebase project as `clientapp`.** Copy
  `clientapp/android/app/google-services.json` into the new app
  module unchanged. No new Firebase project, no Firestore rules
  changes — `clientapp/firestore.rules` already governs this data and
  already supports the client-write patterns this app needs (create
  own donation as Pending, create own problem, vote via
  `problems/{id}/votes/{uid}`, manage own `notification_reads`).
- **Firestore collections** (ported 1:1 from `clientapp/lib/models.dart`
  into Kotlin `data class`es with the same field-reading defensiveness
  — tolerate missing/wrong-typed fields rather than crash):
  `villages/{villageId}`, `users/{userId}`, `citizens/{citizenId}`
  (legacy, public read), `donations/{donationId}`,
  `fund_transactions/{transactionId}`, `projects/{projectId}`,
  `notifications/{notificationId}`, `problems/{problemId}` with
  `votes/{voterId}` subcollection, `config/{configId}` (payment
  methods).
- **Auth convention:** replicate `AuthService` from
  `clientapp/lib/services/auth_service.dart` exactly:
  - Phone+password login signs in with Firebase Email/Password auth
    using the synthetic email `{normalizedPhone}@village.app` — no
    real SMS/OTP flow, no Firebase Phone Auth API.
  - Google sign-in via Firebase `GoogleAuthProvider`, using Android
    Credential Manager / One Tap (the modern Android equivalent of the
    `google_sign_in` package), same OAuth web client ID
    (`1064035305311-2ovc90ovj0ujdslrgpot09id15uhuho7.apps.googleusercontent.com`).
  - Plain email+password sign-in for users registered that way.
  - On first Google sign-in, upsert a `users/{uid}` profile document
    the same way `_upsertUserProfile()` does.
- **Push notifications:** Firebase Cloud Messaging, matching
  `clientapp/lib/push_notification_service.dart`'s topic/registration
  approach.

## Testing

- Unit tests for ViewModels and Repositories (JVM, no emulator) using
  fake/in-memory Firestore data — mirrors `clientapp/test/`'s existing
  coverage of parsing and service logic.
- No UI/instrumented test requirement for v1, given scope.

## Non-goals / explicitly deferred

- No changes to `admin` or `clientapp`.
- No offline sync layer beyond what Firestore's SDK provides by
  default (clientapp has a custom `SyncService`/connectivity layer;
  v1 of the native app can rely on Firestore's built-in offline cache
  and revisit a custom sync layer later if needed).

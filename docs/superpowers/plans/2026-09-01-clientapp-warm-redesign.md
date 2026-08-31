# Clientapp Warm Community Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Re-skin the clientapp's design tokens to a warm/organic palette, add a shared tinted-icon-badge widget, rebuild the two weakest screens (onboarding, splash), and sweep remaining screens for leftover raw colors — all without changing app behavior, navigation, or data flow.

**Architecture:** The app already has a token-driven theme system (`lib/core/theme/`). This plan changes token *values* (not names) so every screen that already consumes `AppColors`/`AppSpacing`/`AppRadius`/`context.*` updates automatically, then targets the handful of screens/spots that don't yet follow the system.

**Tech Stack:** Flutter, Material 3, existing packages only (no new dependencies).

**Spec:** `docs/superpowers/specs/2026-09-01-clientapp-warm-redesign-design.md`

## Global Constraints

- No new pub dependencies (custom-only redesign, per spec).
- No changes to `lib/services/*`, providers, or `lib/core/router/app_router.dart` — visuals only.
- Every task ends with `flutter analyze` reporting no new issues.
- Keep existing token *names* stable — only values change — so unlisted screens keep working without edits.
- New palette values (exact, from spec):
  - `primary` = `0xFF3F8A4E`, `primaryDark` = `0xFF2E6B3D`, `primaryLight` = `0xFF6FAE6E`, `primaryContainer` = `0xFFEEF3E7`
  - `accentTerracotta` = `0xFFD97757` (new), `accentGold` = `0xFFE8A94C` (new)
  - `warning` = `0xFFE8A94C` (reuse accentGold value)
  - `lightCanvas` = `0xFFFBF8F3`, `lightBorder` = `0xFFE8E0D4`
  - `darkCanvas` = `0xFF14120F`, `darkSurface` = `0xFF1C1814`, `darkBorder` = `0xFF33291F`

---

### Task 1: Re-skin color tokens and remove deprecated aliases

**Files:**
- Modify: `clientapp/lib/core/theme/app_colors.dart`
- Modify: `clientapp/lib/features/onboarding/onboarding_screen.dart:75` (only the `context.background` call site changed by this task)

**Interfaces:**
- Produces: `AppColors.accentTerracotta`, `AppColors.accentGold` (new static `Color` constants) — used by Task 3 (`CategoryIconBadge`) and Task 4/8 (icon badge color rotation).
- Produces: `context.accentTerracotta`, `context.accentGold` getters on `ContextColors` extension — same consumers.

- [ ] **Step 1: Update the brand and warning colors**

In `clientapp/lib/core/theme/app_colors.dart`, replace lines 13–39 (the `primary` through `infoContainer` block) with:

```dart
  // ── Brand Moss Green ─────────────────────────
  /// Primary action color — warm moss green
  static const Color primary = Color(0xFF3F8A4E);

  /// Pressed / gradient end
  static const Color primaryDark = Color(0xFF2E6B3D);

  /// Hover / gradient start (lighter)
  static const Color primaryLight = Color(0xFF6FAE6E);

  /// Muted green for dark-mode secondary
  static const Color primaryMuted = Color(0xFF9BC49A);

  /// Tinted surface — chip, badge backgrounds
  static const Color primaryContainer = Color(0xFFEEF3E7);

  // ── Warm Accents ─────────────────────────────
  /// CTAs, highlights, one of the icon-badge rotation colors
  static const Color accentTerracotta = Color(0xFFD97757);

  /// Achievements, top-contributor badges, warning color
  static const Color accentGold = Color(0xFFE8A94C);

  // ── Semantic ─────────────────────────────────
  static const Color success = Color(0xFF2E6B3D);
  static const Color successLight = Color(0xFF3F8A4E);
  static const Color successContainer = Color(0xFFEEF3E7);

  static const Color warning = accentGold;
  static const Color warningContainer = Color(0xFFFBF3E4);

  static const Color error = Color(0xFFC1502E);
  static const Color errorContainer = Color(0xFFFBEEE8);

  static const Color info = Color(0xFF3B6E8F);
  static const Color infoContainer = Color(0xFFE9F0F4);
```

- [ ] **Step 2: Warm up text ink and surface colors**

In the same file, replace the `// ── Text ─────` block (old lines 41-54) with:

```dart
  // ── Text ─────────────────────────────────────
  static const Color ink900 = Color(0xFF1B1712);   // Near black — headlines
  static const Color ink700 = Color(0xFF433C33);   // Body text
  static const Color ink500 = Color(0xFF766D5F);   // Secondary text
  static const Color ink300 = Color(0xFFAEA595);   // Tertiary / placeholder
  static const Color inkOnPrimary = Color(0xFFFFFFFF);
```

Delete the old `// ── Backward-compat static aliases ───────────` block entirely (old lines 48-54: `lightBackground`, `textSecondary`, `textTertiary` deprecated aliases) — they're being removed per the spec.

Replace the `// ── Light Surface System ──────────────────────` block (old lines 57-71) with:

```dart
  // ── Light Surface System ──────────────────────
  /// Warm cream — main page background
  static const Color lightCanvas = Color(0xFFFBF8F3);

  /// Pure white — card / surface
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Warm tan-gray border
  static const Color lightBorder = Color(0xFFE8E0D4);

  /// Slightly more visible divider
  static const Color lightDivider = Color(0xFFF1ECE1);

  /// Input field fill
  static const Color lightInputFill = Color(0xFFFBF8F3);
```

Replace the `// ── Dark Surface System ───────────────────────` block (old lines 73-90) with:

```dart
  // ── Dark Surface System ───────────────────────
  /// Deep warm near-black background
  static const Color darkCanvas = Color(0xFF14120F);

  /// Card / elevated surface in dark
  static const Color darkSurface = Color(0xFF1C1814);

  /// Slightly lighter card for nested elements
  static const Color darkCard = Color(0xFF241F18);

  /// Visible but subtle warm border in dark
  static const Color darkBorder = Color(0xFF33291F);

  /// Softer divider in dark
  static const Color darkDivider = Color(0xFF2A2319);

  /// Input fill in dark
  static const Color darkInputFill = Color(0xFF241F18);
```

- [ ] **Step 3: Add context getters for the new accent colors and remove deprecated getter aliases**

In the `ContextColors` extension (bottom of the file), after the existing `Color get primaryContainer => AppColors.primaryContainer;` line, add:

```dart
  Color get accentTerracotta => AppColors.accentTerracotta;
  Color get accentGold       => AppColors.accentGold;
```

Find the `// Backward-compat alias` block at the bottom (`Color get background => canvas;`) — leave `background` itself (it's not deprecated, only the three static aliases were), but confirm there is no `textSecondary`/`textTertiary` duplicate definition left over from the deleted static aliases (there shouldn't be, since those were `AppColors` statics, not extension getters — the extension already defines its own theme-aware `textSecondary`/`textTertiary` getters, which stay).

- [ ] **Step 4: Fix the one call site that used the deprecated static alias**

`context.background` (used in `onboarding_screen.dart:75`) is the *extension getter*, not the deleted static alias — it's unaffected and stays as-is. Grep to confirm nothing references the deleted statics directly:

```bash
cd clientapp && grep -rn "AppColors.lightBackground\|AppColors.textSecondary\|AppColors.textTertiary" lib/
```

Expected: no output. If any call sites appear, replace `AppColors.lightBackground` → `AppColors.lightCanvas`, `AppColors.textSecondary` → `context.textSecondary`, `AppColors.textTertiary` → `context.textTertiary` at each site, then re-run the grep to confirm it's clean.

- [ ] **Step 5: Verify and commit**

```bash
cd clientapp && flutter analyze lib/core/theme/app_colors.dart
```
Expected: `No issues found!`

```bash
cd clientapp && flutter analyze
```
Expected: no new errors (existing warnings, if any, are pre-existing and out of scope).

```bash
git add clientapp/lib/core/theme/app_colors.dart
git commit -m "feat(design): re-skin color tokens to warm community palette"
```

---

### Task 2: Soften card shape and shadows

**Files:**
- Modify: `clientapp/lib/core/theme/app_theme.dart:113-127` (`cardTheme`)
- Modify: `clientapp/lib/features/home/home_screen.dart:313-329` (hero balance card shadow)

**Interfaces:**
- Consumes: `AppRadius.xxxlBorder` (existing, from `app_radius.dart`), `AppColors.shadowLight`/`shadowMedium` (existing).
- No new interfaces produced — this only changes constant values used by existing widgets.

- [ ] **Step 1: Update the global card theme**

In `clientapp/lib/core/theme/app_theme.dart`, in the `cardTheme: CardThemeData(...)` block, change:

```dart
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xxlBorder,
```
to:
```dart
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xxxlBorder,
```

(Same block, no other lines change — border color/width and elevation stay as-is.)

- [ ] **Step 2: Flatten the home screen hero card shadow**

In `clientapp/lib/features/home/home_screen.dart`, in `_buildHeroBalanceCard`, change:

```dart
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
```
to:
```dart
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
```

- [ ] **Step 3: Verify and commit**

```bash
cd clientapp && flutter analyze
```
Expected: no new issues.

```bash
git add clientapp/lib/core/theme/app_theme.dart clientapp/lib/features/home/home_screen.dart
git commit -m "feat(design): flatten card shadows and soften corner radius"
```

---

### Task 3: Add the `CategoryIconBadge` shared widget

**Files:**
- Create: `clientapp/lib/core/widgets/category_icon_badge.dart`
- Test: manual (visual widget, no unit-testable behavior — verified by `flutter analyze` + adoption in Task 4)

**Interfaces:**
- Consumes: nothing new (`flutter/material.dart` only).
- Produces: `CategoryIconBadge({required IconData icon, required Color color, double size = 40})` — a `StatelessWidget`. Used by Task 4 (home screen) and Task 8 (sweep).

- [ ] **Step 1: Create the widget file**

```dart
// clientapp/lib/core/widgets/category_icon_badge.dart
import 'package:flutter/material.dart';

/// A rounded, tinted-circle icon used to mark a category (donation, problem,
/// project, notification, ...). Rotate [color] through
/// `AppColors.primary` / `accentTerracotta` / `accentGold` / `info` by
/// category for visual variety — see call sites for the convention.
class CategoryIconBadge extends StatelessWidget {
  const CategoryIconBadge({
    required this.icon,
    required this.color,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
```

- [ ] **Step 2: Verify and commit**

```bash
cd clientapp && flutter analyze lib/core/widgets/category_icon_badge.dart
```
Expected: `No issues found!`

```bash
git add clientapp/lib/core/widgets/category_icon_badge.dart
git commit -m "feat(design): add CategoryIconBadge shared widget"
```

---

### Task 4: Adopt `CategoryIconBadge` in the home screen

**Files:**
- Modify: `clientapp/lib/features/home/home_screen.dart`

**Interfaces:**
- Consumes: `CategoryIconBadge` from Task 3 (`import '../../core/widgets/category_icon_badge.dart';`).

- [ ] **Step 1: Replace the notification bell container's inner icon (header)**

This one stays a square (it's a nav button, not a category marker) — **no change** to `_buildHeader`'s notification container. (Documenting explicitly so the implementer doesn't touch it by mistake — only the two containers below are category badges.)

- [ ] **Step 2: Replace the hero card's balance icon container**

In `_buildHeroBalanceCard`, change:

```dart
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.inkOnPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.inkOnPrimary,
                  size: 20,
                ),
              ),
```
to:
```dart
              CategoryIconBadge(
                icon: Icons.account_balance_rounded,
                color: AppColors.inkOnPrimary,
                size: 36,
              ),
```

(This keeps the white-on-gradient look — `CategoryIconBadge` tints at 14% alpha same as the old container's 15%, close enough visually; the circle shape is the intended change.)

- [ ] **Step 3: Add the import**

At the top of `home_screen.dart`, add:
```dart
import '../../core/widgets/category_icon_badge.dart';
```

- [ ] **Step 4: Verify and commit**

```bash
cd clientapp && flutter analyze lib/features/home/home_screen.dart
```
Expected: `No issues found!`

```bash
git add clientapp/lib/features/home/home_screen.dart
git commit -m "feat(design): adopt CategoryIconBadge in home screen hero card"
```

---

### Task 5: Rebuild the onboarding screen

**Files:**
- Modify: `clientapp/lib/features/onboarding/onboarding_screen.dart`

**Interfaces:**
- Consumes: `AppSpacing` (new import), `AppColors.accentTerracotta`/`accentGold` (Task 1), `CategoryIconBadge` (Task 3) — used for the feature-page icon.
- No public interface changes — `OnboardingScreen` stays a `ConsumerStatefulWidget` with no constructor params, same route usage in `app_router.dart` (unchanged).

- [ ] **Step 1: Add the `AppSpacing` import**

At the top of `onboarding_screen.dart`, add:
```dart
import '../../core/theme/app_spacing.dart';
```

- [ ] **Step 2: Replace hardcoded paddings with `AppSpacing`**

Replace:
```dart
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
```
with:
```dart
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
              ),
```

Replace:
```dart
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
```
with:
```dart
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl,
              ),
```

- [ ] **Step 3: Replace the feature-page icon container with `CategoryIconBadge`**

Add the import:
```dart
import '../../core/widgets/category_icon_badge.dart';
```

In `_FeaturePageView.build`, replace:
```dart
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: context.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: context.primary.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Icon(page.icon, color: context.primary, size: 56),
          ),
```
with:
```dart
          CategoryIconBadge(
            icon: page.icon,
            color: context.primary,
            size: 132,
          ),
```

- [ ] **Step 4: Rotate icon-badge colors per feature page**

`_OnboardingPage` currently has no color field, and `_FeaturePageView` always uses `context.primary`. Add a `color` field so each of the 4 feature pages gets a distinct badge color (matching the spec's category rotation: primary/terracotta/gold/info).

In the `_OnboardingPage` class, add a field:
```dart
class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.titleBn,
    required this.descBn,
    required this.color,
  });

  final IconData icon;
  final String titleBn;
  final String descBn;
  final Color color;
}
```

Update the `_featurePages` list to pass a `color` for each entry, in order:
```dart
  static const _featurePages = [
    _OnboardingPage(
      icon: Icons.account_balance_wallet_rounded,
      titleBn: 'স্বচ্ছ গ্রাম তহবিল',
      descBn: 'প্রতিটি অনুদান ও খরচ রিয়েল-টাইমে ট্র্যাক করুন। গ্রামের তহবিল কিভাবে ব্যবহার হচ্ছে তা দেখুন।',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      icon: Icons.construction_rounded,
      titleBn: 'উন্নয়ন প্রকল্প',
      descBn: 'গ্রাম উন্নয়ন প্রকল্প, তাদের অগ্রগতি এবং খরচের রিপোর্ট পর্যবেক্ষণ করুন।',
      color: AppColors.accentGold,
    ),
    _OnboardingPage(
      icon: Icons.report_problem_rounded,
      titleBn: 'সমস্যা রিপোর্ট',
      descBn: 'ছবি ও অবস্থান সহ গ্রামের সমস্যা রিপোর্ট করুন। সমাধানের অগ্রগতি ট্র্যাক করুন।',
      color: AppColors.accentTerracotta,
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      titleBn: 'জনগণের অংশগ্রহণ',
      descBn: 'আপনার গ্রামের কমিউনিটিতে যোগ দিন। অনুদান দিন, অংশগ্রহণ করুন এবং একসাথে পরিবর্তন আনুন।',
      color: AppColors.info,
    ),
  ];
```

Add the `AppColors` import if not already present:
```dart
import '../../core/theme/app_colors.dart';
```
(Already imported at line 5 — no change needed there.)

Update `_FeaturePageView.build` to use `page.color` instead of `context.primary`:
```dart
          CategoryIconBadge(
            icon: page.icon,
            color: page.color,
            size: 132,
          ),
```
And update the title/description styling below it — no color change needed there (title/description stay `context.textPrimary`/`context.textSecondary`, only the badge is per-page-colored).

- [ ] **Step 5: Verify and commit**

```bash
cd clientapp && flutter analyze lib/features/onboarding/onboarding_screen.dart
```
Expected: `No issues found!`

```bash
git add clientapp/lib/features/onboarding/onboarding_screen.dart
git commit -m "feat(design): rebuild onboarding screen with tokens and category badges"
```

---

### Task 6: Update the splash screen gradient to the new palette

**Files:**
- Modify: `clientapp/lib/features/splash/splash_screen.dart`

**Interfaces:**
- Consumes: `AppColors.primary`/`AppColors.primaryDark` (Task 1) — replaces raw hex.

- [ ] **Step 1: Add the `AppColors` import**

At the top of `splash_screen.dart`, add:
```dart
import '../../core/theme/app_colors.dart';
```

- [ ] **Step 2: Replace the raw gradient colors**

Replace:
```dart
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          ),
        ),
```
with:
```dart
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
```

- [ ] **Step 3: Verify and commit**

```bash
cd clientapp && flutter analyze lib/features/splash/splash_screen.dart
```
Expected: `No issues found!`

```bash
git add clientapp/lib/features/splash/splash_screen.dart
git commit -m "feat(design): use warm palette tokens in splash screen gradient"
```

---

### Task 7: Soften the entrance/press motion curve

**Files:**
- Modify: `clientapp/lib/core/widgets/motion.dart`

**Interfaces:**
- No signature changes — `FadeSlideIn`'s default `curve` value changes; all existing call sites (which don't pass `curve` explicitly) pick up the new default automatically.

- [ ] **Step 1: Change the default curve**

In `FadeSlideIn`'s constructor, change:
```dart
    this.curve = Curves.easeOutCubic,
```
to:
```dart
    this.curve = Curves.easeOutBack,
```

- [ ] **Step 2: Verify and commit**

```bash
cd clientapp && flutter analyze lib/core/widgets/motion.dart
```
Expected: `No issues found!`

Manually sanity-check on a running emulator/device that the home screen's staggered entrance (`FadeSlideIn` used throughout `home_screen.dart`) doesn't overshoot distractingly — `Curves.easeOutBack` has a slight bounce; at the current 18px offset this should read as a gentle settle, not a wobble. If it looks excessive, revert to `Curves.easeOutCubic` and note that in the commit message instead.

```bash
git add clientapp/lib/core/widgets/motion.dart
git commit -m "feat(design): switch FadeSlideIn default easing to easeOutBack"
```

---

### Task 8: Sweep remaining raw colors and the stray `ListTile`

**Files:**
- Modify: `clientapp/lib/features/auth/login_screen.dart`
- Modify: `clientapp/lib/features/donation/donation_screen.dart`
- Modify: `clientapp/lib/features/donation/donation_checkout_screen.dart`
- Modify: `clientapp/lib/features/problems/problems_screen.dart`

**Interfaces:**
- Consumes: `AppColors`/`context.*` tokens (Task 1), `PremiumCard` (existing, from `clientapp/lib/core/widgets/glass_card.dart` — read that file's exported widget name before Step 3 below if it differs from `PremiumCard`).

- [ ] **Step 1: Find every raw color literal in the four files**

```bash
cd clientapp && grep -n "Color(0x" lib/features/auth/login_screen.dart lib/features/donation/donation_screen.dart lib/features/donation/donation_checkout_screen.dart lib/features/problems/problems_screen.dart
```

- [ ] **Step 2: Replace each raw color with its token equivalent**

For each match from Step 1, open the file at that line and replace the literal with the semantically closest token:
- A literal matching the old brand green (`0xFF22C55E`, `0xFF16A34A`, `0xFF4ADE80`) → `AppColors.primary` / `AppColors.primaryDark` / `AppColors.primaryLight` respectively.
- A literal used for success/error/warning/info tints → `AppColors.success` / `AppColors.error` / `AppColors.warning` / `AppColors.info` (match by the surrounding usage — e.g. a green checkmark background is `success`, a red error icon is `error`).
- A literal used for neutral/surface/border → `context.surface` / `context.border` / `context.divider` as appropriate (match by usage — a card background is `context.surface`, a hairline is `context.border`).
- If a literal doesn't map cleanly to an existing token (e.g. a one-off shadow alpha), leave it and note it in the commit message rather than inventing a new token for a single call site.

After editing, re-run the Step 1 grep on each file to confirm the count dropped to only the literals you deliberately left (if any).

- [ ] **Step 3: Fix the stray `ListTile` in the checkout screen**

Read `clientapp/lib/core/widgets/glass_card.dart` first to get the exact exported widget name and constructor signature (the spec calls it `PremiumCard`; confirm before using it — if the file exports a differently-named widget, use that name instead throughout this step).

In `donation_checkout_screen.dart`, find the `ListTile(` call (from the earlier audit). Replace it with a row built the same way its sibling rows in the same screen are built — read at least one neighboring row in the same file first and match its exact structure (padding, `PremiumCard` wrapper, text styles) rather than inventing a new pattern. The replacement must preserve the original `ListTile`'s `leading`/`title`/`subtitle`/`trailing`/`onTap` content and behavior — only the container/styling changes.

- [ ] **Step 4: Verify and commit**

```bash
cd clientapp && flutter analyze
```
Expected: no new issues.

Manually check on an emulator/device: open Login, Donation, Donation Checkout, and Problems screens in both light and dark mode; confirm no leftover green-on-old-palette color clashes and that the checkout screen's former `ListTile` row now visually matches its neighbors.

```bash
git add clientapp/lib/features/auth/login_screen.dart clientapp/lib/features/donation/donation_screen.dart clientapp/lib/features/donation/donation_checkout_screen.dart clientapp/lib/features/problems/problems_screen.dart
git commit -m "feat(design): sweep raw colors and fix checkout screen row styling"
```

---

### Task 9: Final full-app verification pass

**Files:** none (verification only)

**Interfaces:** none.

- [ ] **Step 1: Run the full analyzer**

```bash
cd clientapp && flutter analyze
```
Expected: `No issues found!`

- [ ] **Step 2: Run the existing test suite**

```bash
cd clientapp && flutter test
```
Expected: all tests pass (this work doesn't touch `lib/services/*`, so `test/services/*` and `test/widget_test.dart` should be unaffected — a failure here means a regression, not a design choice).

- [ ] **Step 3: Manual visual pass**

Run the app on an emulator/device (`flutter run`) and walk: splash → onboarding → login → home → donation → donation checkout → problems → citizens, in both light and dark mode (toggle via device/system theme). Confirm:
- No screen shows the old cool-gray/bright-green palette.
- Card corners and shadows look consistently flatter/softer than before.
- The onboarding feature pages show 4 distinct badge colors (green/gold/terracotta/blue).
- No visual regression (text cut off, missing icons, broken layout) on any screen touched by this plan.

- [ ] **Step 4: Final commit (if manual pass required fixes)**

If Step 3 surfaced any fixes, make them, re-run Steps 1–2, then:
```bash
git add -A
git commit -m "fix(design): address issues found in manual visual pass"
```

If Step 3 found nothing to fix, no commit is needed for this task — Task 8's commit is the last one.

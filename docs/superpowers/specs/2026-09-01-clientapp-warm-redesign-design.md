# Clientapp Warm Community Redesign

## Context

The Flutter clientapp (`clientapp/`) already has a mature token-based design
system (`lib/core/theme/`) and most screens use it correctly — a prior audit
found `login_screen.dart`, `donation_screen.dart`, `problems_screen.dart`,
`citizen_directory_screen.dart`, `projects_screen.dart`, `profile_screen.dart`,
`settings_screen.dart`, `leaders_screen.dart`, `shell_screen.dart`, and
`notification_screen.dart` all wired to `AppColors`/`AppSpacing`/`AppRadius`
tokens with consistent motion (`PressScale`, `FadeSlideIn`) and card styling
(`PremiumCard`).

The user still wants a full visual redesign, not just a consistency pass, to
move from the current "Vibrant Modern Bengali" (bright green gradients, heavy
shadows) look to a **Warm Community/Organic** direction: earthier palette,
softer rounded shapes, and a distinctive "tinted icon badge" treatment that
reads as warm/organic without requiring new illustration assets (user chose
custom-only, no third-party UI kit).

Known trouble spots from the audit, in priority order:
1. `onboarding_screen.dart` — barely touches the token system (8 token hits /
   556 lines), raw `EdgeInsets.fromLTRB(...)`, uses deprecated
   `context.background`. First screen a new user sees.
2. `splash_screen.dart` — thin token use (4/218), no brand treatment.
3. `login_screen.dart`, `donation_checkout_screen.dart` — mostly on-system but
   a handful of raw `Color(0x...)` literals, plus one default `ListTile` in
   the checkout screen that visually clashes with its `PremiumCard` siblings.
4. `app_colors.dart` carries 3 `@deprecated` aliases (`lightBackground`,
   `textSecondary`, `textTertiary`) that should be removed once call sites are
   clear.

## Goals

- Replace the token *values* (palette, radius, shadow) with the new warm
  palette, without breaking the token *architecture* (screens keep consuming
  `AppColors`/`AppSpacing`/`AppRadius`/`context.textPrimary` etc. — this is a
  re-skin of the token layer plus a rebuild of the two weakest screens, not a
  rewrite of every screen's structure).
- Add one new shared widget, `CategoryIconBadge`, that renders a rounded
  tinted-circle icon (the "organic" signal), and adopt it wherever a screen
  currently hand-rolls a square tinted icon container.
- Rebuild `onboarding_screen.dart` and `splash_screen.dart` to fully use the
  token system and match the new visual language.
- Sweep the remaining screens for raw hex colors, the stray `ListTile`, and
  the deprecated color aliases.
- Keep behavior identical — this is visuals only. No new dependencies, no
  changed navigation, no changed data flow.

## Non-goals

- No new third-party UI component library (user decision).
- No new illustration/SVG assets (keep it token + icon-badge driven).
- No restructuring of screens that already follow the token system correctly
  (their layout/composition stays; only token *values* and icon containers
  change under them).
- No changes to `lib/services/*`, providers, or routing.

## Design

### 1. Palette (`lib/core/theme/app_colors.dart`)

Replace the "Premium Green" palette with a warm palette. Keep the same
*names* (`primary`, `primaryDark`, `primaryLight`, `success`, `warning`,
`error`, `info`, `ink*`, `lightCanvas`, `darkCanvas`, etc.) so every
consuming screen keeps working unchanged — only the `Color(0x...)` values and
a few additions change:

| Token | Old | New | Notes |
|---|---|---|---|
| `primary` | `#22C55E` | `#3F8A4E` (warm moss) | brand green, shifted warmer/darker |
| `primaryDark` | `#16A34A` | `#2E6B3D` | |
| `primaryLight` | `#4ADE80` | `#6FAE6E` | |
| `primaryContainer` | `#F0FDF4` | `#EEF3E7` (warm sage tint) | |
| *(new)* `accentTerracotta` | — | `#D97757` | CTAs/highlights |
| *(new)* `accentGold` | — | `#E8A94C` | achievements / top contributor |
| `warning` | `#F59E0B` | `#E8A94C` (reuse gold) | unify with accentGold |
| `lightCanvas` | `#F9FAFB` (cool gray) | `#FBF8F3` (warm cream) | |
| `lightSurface` | `#FFFFFF` | `#FFFFFF` | unchanged, but card border warms up |
| `lightBorder` | `#E5E7EB` | `#E8E0D4` (warm tan-gray) | |
| `darkCanvas` | `#0C0F0E` | `#14120F` (warm near-black) | |
| `darkSurface` | `#161B19` | `#1C1814` | |
| `darkBorder` | `#2C3531` | `#33291F` | |
| `ink900`/`ink700`/`ink500`/`ink300` | cool grays | shift 3–5% warmer (add a touch of red/yellow) | keeps contrast ratios, just warms the gray |

Remove the 3 `@deprecated` aliases (`lightBackground`, `textSecondary`,
`textTertiary`) — grep for remaining call sites first and update them to the
non-deprecated equivalent (`lightCanvas` / `context.textSecondary` /
`context.textTertiary`) as part of this change.

Contrast check: verify new `ink*` values still meet WCAG AA against
`lightCanvas`/`darkCanvas` (4.5:1 body text) — spot check with a contrast
calculator during implementation, adjust lightness if any pairing fails.

### 2. Shape & shadow (`app_radius.dart`, `app_theme.dart`)

- Bump the card corner radius used by `PremiumCard`/`cardTheme` from the
  current `xxl` (24) to `xxxl` (32) — softer, more organic.
- Card shadow: replace the current colored/heavy shadows (e.g. the hero
  balance card's `AppColors.primary.withValues(alpha: 0.28), blurRadius: 28`)
  with a single soft warm-neutral shadow (`shadowLight`/`shadowMedium`,
  already token-driven) at lower blur (12–16) — flatter, less "glowing."
- `app_radius.dart` values themselves (`xs(6)` … `xxxl(32)`, `full(999)`)
  stay as-is; just which constant each component reaches for shifts.

### 3. New shared widget: `CategoryIconBadge`

New file `lib/core/widgets/category_icon_badge.dart`:

```dart
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

Rotate through `AppColors.primary` / `accentTerracotta` / `accentGold` /
`info` by category (donation = primary, problem = terracotta, project =
gold, notification = info) for visual variety, applied consistently at each
call site. Replace hand-rolled square `Container` + `BoxDecoration` icon
containers across screens (home quick actions, KPI cards, timeline items,
list rows) with this widget where it fits the existing layout without
restructuring.

### 4. Motion (`lib/core/widgets/motion.dart`)

Swap the curve used by `FadeSlideIn`/`PressScale` from the current
easing to `Curves.easeOutBack` (or a low-overshoot custom cubic if
`easeOutBack`'s overshoot looks excessive at small distances) — same
duration/API, just a friendlier feel. No signature changes, so no call
sites need touching.

### 5. Screen rebuilds

**`onboarding_screen.dart`** and **`splash_screen.dart`**: full rebuild in
the new visual language — token-driven spacing/colors throughout, splash
gets a simple brand treatment (warm gradient or solid `primary` background +
logo, matching the hero card language), onboarding gets the same
card/spacing/motion conventions the rest of the app uses. No change to their
navigation/routing responsibilities (splash still redirects based on auth
state; onboarding still marks completion the same way) — visuals only.

**Sweep** (`login_screen.dart`, `donation_screen.dart`,
`donation_checkout_screen.dart`, `problems_screen.dart`): replace remaining
raw `Color(0x...)` literals with the matching `AppColors`/`context.*` token,
and replace the stray `ListTile` in `donation_checkout_screen.dart` with a
`PremiumCard`-based row matching its siblings.

### Testing

- `flutter analyze` clean after each phase.
- No automated visual tests (subjective design work) — manual pass on an
  emulator/device covering: splash → onboarding → home → donation →
  checkout → problems → citizens, in both light and dark mode, checking
  contrast and that no screen regressed to the old palette.
- Existing unit tests (`test/services/*`) must still pass — this work
  doesn't touch service logic, so they're a regression guard, not a target.

### Rollout order (for the implementation plan)

1. Re-skin tokens: `app_colors.dart`, `app_radius.dart` usage in
   `app_theme.dart`, remove deprecated aliases (grep + fix call sites first).
2. Add `CategoryIconBadge`; adopt it in `home_screen.dart` (already read,
   known icon-container call sites: quick actions, KPI cards, timeline
   items).
3. Rebuild `onboarding_screen.dart`.
4. Rebuild `splash_screen.dart`.
5. Sweep `login_screen.dart`, `donation_screen.dart`,
   `donation_checkout_screen.dart` (incl. `ListTile` fix), `problems_screen.dart`
   for raw colors + adopt `CategoryIconBadge` where an icon container exists.
6. Sweep remaining screens (`citizen_directory_screen.dart`,
   `citizen_profile_screen.dart`, `projects_screen.dart`, `profile_screen.dart`,
   `settings_screen.dart`, `notification_screen.dart`, `leaders_screen.dart`,
   `problem_details_screen.dart`, `report_problem_screen.dart`,
   `shell_screen.dart`) for `CategoryIconBadge` adoption and any stray raw
   colors.
7. Full `flutter analyze` + manual pass across light/dark mode.

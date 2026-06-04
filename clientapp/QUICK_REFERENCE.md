# গ্রামবাসী - Quick Reference Guide for Developers

## 🚀 Fast Track Setup

### 1. Import Everything You Need
```dart
import 'package:doulatpara/design_system/index.dart';
import 'package:doulatpara/premium_screens/index.dart';
```

### 2. Setup Theme in main.dart
```dart
void main() => runApp(const GramBaseeApp());

class GramBaseeApp extends StatelessWidget {
  const GramBaseeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'গ্রামবাসী',
      theme: GramBaseeTheme.lightTheme(),
      darkTheme: GramBaseeTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const PremiumBottomNavigation(),
    );
  }
}
```

---

## 🎨 Color Reference

### Always Use These
```dart
// Primary & semantic
GramBaseeColors.primary           // #22C55E
GramBaseeColors.success           // #22C55E
GramBaseeColors.warning           // #F59E0B
GramBaseeColors.error             // #EF4444
GramBaseeColors.info              // #3B82F6

// Neutral - Light mode
GramBaseeColors.backgroundLight   // #FFFFFF
GramBaseeColors.surfaceLight      // #FAFAFA
GramBaseeColors.cardLight         // #FBFBFB
GramBaseeColors.textPrimary       // #000000
GramBaseeColors.textSecondary     // #64748B

// Neutral - Dark mode
GramBaseeColors.backgroundDark    // #1A1A1A
GramBaseeColors.surfaceDark       // #0F0F0F
GramBaseeColors.cardDark          // #242424
GramBaseeColors.textPrimaryDark   // #FAFAFA
GramBaseeColors.textSecondaryDark // #BCBCBC

// Don't hardcode colors!
❌ Color(0xFF22C55E)
✅ GramBaseeColors.primary
```

---

## 📏 Spacing Quick Guide

```dart
// Use these constants
const GramBaseeSpacing.xs = 4.0;      // Micro
const GramBaseeSpacing.sm = 8.0;      // Small
const GramBaseeSpacing.md = 12.0;     // Medium
const GramBaseeSpacing.lg = 16.0;     // Standard
const GramBaseeSpacing.xl = 24.0;     // Large
const GramBaseeSpacing.xxl = 32.0;    // Extra large
const GramBaseeSpacing.xxxl = 48.0;   // Huge

// Common patterns
EdgeInsets.all(GramBaseeSpacing.lg)                    // All sides
EdgeInsets.symmetric(                                  // Top/bottom & left/right
  horizontal: GramBaseeSpacing.lg,
  vertical: GramBaseeSpacing.xl,
)
SizedBox(height: GramBaseeSpacing.md)                  // Vertical spacing
SizedBox(width: GramBaseeSpacing.lg)                   // Horizontal spacing
```

---

## ✍️ Typography Quick Guide

### Text Styles with Theme Support
```dart
// Always pass isDark parameter!
final isDark = Theme.of(context).brightness == Brightness.dark;

// Display (headings)
GramBaseeTypography.displayLarge(isDark: isDark)      // 40px, 700
GramBaseeTypography.displayMedium(isDark: isDark)     // 32px, 700
GramBaseeTypography.displaySmall(isDark: isDark)      // 28px, 600

// Heading (titles)
GramBaseeTypography.headingLarge(isDark: isDark)      // 24px, 600
GramBaseeTypography.headingMedium(isDark: isDark)     // 20px, 600
GramBaseeTypography.headingSmall(isDark: isDark)      // 18px, 600

// Body (content)
GramBaseeTypography.bodyLarge(isDark: isDark)         // 16px, 500
GramBaseeTypography.bodyMedium(isDark: isDark)        // 14px, 500
GramBaseeTypography.bodySmall(isDark: isDark)         // 12px, 500

// Label (UI elements)
GramBaseeTypography.labelLarge(isDark: isDark)        // 14px, 600
GramBaseeTypography.labelMedium(isDark: isDark)       // 12px, 600
GramBaseeTypography.labelSmall(isDark: isDark)        // 11px, 600

// Caption (metadata)
GramBaseeTypography.caption(isDark: isDark)           // 13px, 400
```

### Common Text Usage
```dart
// Heading
Text('Title', style: GramBaseeTypography.headingSmall(isDark: isDark))

// Body with custom color
Text(
  'Content',
  style: GramBaseeTypography.bodyMedium(isDark: isDark).copyWith(
    color: isDark 
      ? GramBaseeColors.textSecondaryDark 
      : GramBaseeColors.textSecondary,
  ),
)

// Label for buttons
Text(
  'Button',
  style: GramBaseeTypography.labelLarge(isDark: isDark),
)
```

---

## 🎭 Theme Detection Pattern

Use this everywhere:
```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Scaffold(
    backgroundColor: isDark 
      ? GramBaseeColors.backgroundDark 
      : GramBaseeColors.backgroundLight,
    body: Container(
      color: isDark
        ? GramBaseeColors.cardDark
        : GramBaseeColors.cardLight,
    ),
  );
}
```

---

## 🧩 Component Cheatsheet

### KPI Card
```dart
KPICard(
  label: 'Label',
  value: 'Value',
  subtitle: 'Optional',
  icon: Icons.icon,
  isLoading: false,
  onTap: () {},
)
```

### Status Chip
```dart
StatusChip(
  label: 'Status',
  backgroundColor: color.withOpacity(0.1),
  textColor: color,
  icon: Icons.icon,
)
```

### Premium Button
```dart
PremiumButton(
  label: 'Button',
  onPressed: () {},
  variant: ButtonVariant.primary,  // or .secondary
  size: ButtonSize.large,          // or .medium, .small
  isLoading: false,
  enabled: true,
)
```

### Search Bar
```dart
PremiumSearchBar(
  placeholder: 'Search...',
  onChanged: (value) {},
  onSearch: () {},
)
```

### Timeline Item
```dart
TimelineItem(
  title: 'Title',
  description: 'Description',
  timestamp: DateTime.now(),
  icon: Icons.icon,
  iconColor: color,
  isCompleted: false,
)
```

### Empty State
```dart
EmptyState(
  title: 'Title',
  description: 'Description',
  icon: Icons.icon,
  actionLabel: 'Action',
  onAction: () {},
)
```

### Dialog
```dart
showDialog(
  context: context,
  builder: (context) => PremiumDialog(
    title: 'Title',
    message: 'Message',
    confirmLabel: 'Confirm',
    cancelLabel: 'Cancel',
    onConfirm: () {},
    onCancel: () {},
  ),
)
```

---

## 📱 Common Layout Patterns

### Grid of KPI Cards
```dart
GridView.count(
  crossAxisCount: 2,
  mainAxisSpacing: GramBaseeSpacing.lg,
  crossAxisSpacing: GramBaseeSpacing.lg,
  childAspectRatio: 1.2,
  children: [
    KPICard(...),
    KPICard(...),
  ],
)
```

### List with Timeline Items
```dart
ListView.builder(
  padding: const EdgeInsets.all(GramBaseeSpacing.lg),
  itemCount: items.length,
  itemBuilder: (_, index) => Padding(
    padding: const EdgeInsets.only(bottom: GramBaseeSpacing.md),
    child: TimelineItem(...),
  ),
)
```

### Custom Scrollable Content
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: Text('Title'),
      expandedHeight: 0,
      elevation: 0,
    ),
    SliverPadding(
      padding: const EdgeInsets.all(GramBaseeSpacing.lg),
      sliver: SliverToBoxAdapter(child: content),
    ),
  ],
)
```

### Row with Two Cards
```dart
Row(
  children: [
    Expanded(child: KPICard(...)),
    const SizedBox(width: GramBaseeSpacing.lg),
    Expanded(child: KPICard(...)),
  ],
)
```

---

## 🎬 Loading States Pattern

### Show Loading
```dart
isLoading
  ? ShimmerLoading(height: 24, width: 80)
  : KPICard(...)
```

### Empty State
```dart
isEmpty
  ? EmptyState(
      title: 'No data',
      icon: Icons.inbox,
    )
  : ListView(...)
```

### Button Loading
```dart
PremiumButton(
  label: isLoading ? '' : 'Submit',
  isLoading: isLoading,
  onPressed: () => performAction(),
)
```

---

## 🎨 Container Styling Template

```dart
Container(
  padding: const EdgeInsets.all(GramBaseeSpacing.lg),
  decoration: BoxDecoration(
    color: isDark 
      ? GramBaseeColors.cardDark 
      : GramBaseeColors.cardLight,
    borderRadius: BorderRadius.circular(GramBaseeBorderRadius.card),
    boxShadow: isDark 
      ? GramBaseeShadows.softShadowDark 
      : GramBaseeShadows.softShadow,
  ),
  child: content,
)
```

---

## 🎯 Do's & Don'ts

### ✅ DO
```dart
// Use theme tokens
GramBaseeSpacing.lg
GramBaseeColors.primary
GramBaseeTypography.bodyLarge(isDark: isDark)

// Reuse components
KPICard(...)
PremiumButton(...)

// Support dark mode
final isDark = Theme.of(context).brightness == Brightness.dark;

// Use const constructors
const SizedBox(height: GramBaseeSpacing.lg)

// Theme-aware colors
isDark ? darkColor : lightColor
```

### ❌ DON'T
```dart
// Hardcode values
16.0  // Use GramBaseeSpacing.lg
Color(0xFF22C55E)  // Use GramBaseeColors.primary

// Create custom components
CustomCard(...)  // Use KPICard(...)

// Ignore dark mode
color: Colors.black  // Check isDark first

// Use non-const constructors
SizedBox(height: 16.0)  // Use const

// Single-color usage
color: GramBaseeColors.primary  // Consider isDark for backgrounds
```

---

## 📱 Screen Template

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark 
        ? GramBaseeColors.backgroundDark 
        : GramBaseeColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark 
          ? GramBaseeColors.backgroundDark 
          : GramBaseeColors.backgroundLight,
        title: Text(
          'Title',
          style: GramBaseeTypography.headingMedium(isDark: isDark),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(GramBaseeSpacing.lg),
        children: [
          // Your content here
        ],
      ),
    );
  }
}
```

---

## 🔗 Screen Navigation

```dart
// Push new screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const HomeDashboardScreen(),
  ),
)

// Pop current screen
Navigator.pop(context)

// Replace current screen
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => NewScreen()),
)
```

---

## 🌐 Accessing Components

```dart
// From design_system
import 'package:doulatpara/design_system/index.dart';
// Gives you: GramBaseeColors, GramBaseeTypography, GramBaseeSpacing,
//            GramBaseeTheme, KPICard, StatusChip, etc.

// From screens
import 'package:doulatpara/premium_screens/index.dart';
// Gives you: All 15 screens + navigation
```

---

## 💾 Save This File

Keep this open in your IDE for quick reference while developing!

---

## 🆘 Common Issues

### Q: Colors look wrong?
A: Check if you're getting isDark correctly
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

### Q: Component not showing?
A: Make sure you imported the design_system
```dart
import 'package:doulatpara/design_system/index.dart';
```

### Q: Spacing looks off?
A: Use consistent spacing tokens
```dart
GramBaseeSpacing.lg  // Not 16.0
```

### Q: Text color issue?
A: Pass isDark to typography
```dart
GramBaseeTypography.bodyLarge(isDark: isDark)
```

---

## 📞 Resources

- **DESIGN_SYSTEM.md** - Full design specs
- **PREMIUM_SCREENS.md** - Screen details
- **COMPONENT_SHOWCASE.md** - Component examples
- **Source code** - Inline documentation

---

**Save this page! You'll reference it constantly.** 🚀

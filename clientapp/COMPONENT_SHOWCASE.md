# গ্রামবাসী Design System - Component Showcase

## 🎨 Complete Component Library Reference

All reusable components with usage examples and customization options.

---

## 1. KPI Card 📊

**Purpose**: Display key metrics with icons and optional subtitles

**Usage**:
```dart
KPICard(
  label: 'মোট দান',
  value: '৳५,२५,०००',
  subtitle: '+२५% এই মাসে',
  icon: Icons.volunteer_activism,
  backgroundColor: Colors.blue.withOpacity(0.05),
  isLoading: false,
  onTap: () {},
)
```

**Features**:
- Icon with colored background
- Optional subtitle
- Loading state with shimmer
- Tap callback
- Custom background color
- Light/dark mode support

**Variants**:
- With loading shimmer
- With custom background
- As grid item
- With onTap action

---

## 2. Status Chip 🏷️

**Purpose**: Compact status badges with optional icons

**Usage**:
```dart
StatusChip(
  label: 'চলমান',
  backgroundColor: Colors.orange.withOpacity(0.1),
  textColor: Colors.orange,
  icon: Icons.schedule,
  onTap: () {},
)
```

**Features**:
- Full rounded design (pill shape)
- Optional icon
- Custom colors
- Tap callback
- Inline usage

**Variants**:
- With icon
- Without icon
- Different colors
- Various sizes (via text style)

---

## 3. Premium Button 🔘

**Purpose**: High-quality button with variants and loading states

**Usage**:
```dart
PremiumButton(
  label: 'নতুন দান',
  onPressed: () {},
  variant: ButtonVariant.primary,
  size: ButtonSize.large,
  isLoading: false,
  enabled: true,
)
```

**Features**:
- Primary & Secondary variants
- 3 sizes (Large, Medium, Small)
- Loading state with spinner
- Disabled state
- Soft shadow on primary
- Dark/light mode support

**Variants**:
```dart
// Sizes
ButtonSize.large   // 56dp height
ButtonSize.medium  // 48dp height
ButtonSize.small   // 40dp height

// Variants
ButtonVariant.primary     // Full green with shadow
ButtonVariant.secondary   // Outlined style
```

---

## 4. Premium Search Bar 🔍

**Purpose**: Beautiful search input with icon and callbacks

**Usage**:
```dart
PremiumSearchBar(
  placeholder: 'গ্রাম অনুসন্ধান করুন...',
  onChanged: (value) => setState(() => searchQuery = value),
  onSearch: () => performSearch(),
  controller: searchController,
)
```

**Features**:
- Leading search icon
- Soft shadow
- Smooth border focus
- TextEditingController support
- onChanged & onSearch callbacks
- Placeholder text
- Auto theme detection

---

## 5. Progress Ring 🔄

**Purpose**: Circular progress indicator with centered label

**Usage**:
```dart
ProgressRing(
  progress: 0.65,
  size: 120,
  label: 'প্রকল্প',
  value: '65%',
)
```

**Features**:
- Circular progress animation
- Centered value display
- Label below/inside
- Customizable size
- Green progress color
- Background ring

---

## 6. Timeline Item 📝

**Purpose**: Activity/history feed item with timestamp

**Usage**:
```dart
TimelineItem(
  title: 'নতুন দান গৃহীত',
  description: 'রহিম সাহেব ৳२५,०००',
  timestamp: DateTime.now(),
  icon: Icons.volunteer_activism,
  iconColor: GramBaseeColors.primary,
  isCompleted: false,
)
```

**Features**:
- Leading icon with color
- Title and description
- Relative timestamp (e.g., "2 hours ago")
- Completed state indicator
- Card styling with shadow
- Dark/light mode support

**Timestamp Formatting**:
- Less than 60 seconds: "এখনই"
- Less than 60 minutes: "X মিনিট আগে"
- Less than 24 hours: "X ঘণ্টা আগে"
- Otherwise: "X দিন আগে"

---

## 7. Shimmer Loading ⚡

**Purpose**: Skeleton loader with smooth shimmer animation

**Usage**:
```dart
ShimmerLoading(
  height: 24,
  width: 80,
  borderRadius: GramBaseeBorderRadius.button,
)

// In a list
ListView.builder(
  itemBuilder: (_, index) => isLoading
    ? ShimmerLoading(height: 60)
    : DataRow(...),
)
```

**Features**:
- Smooth shimmer animation (1500ms)
- Customizable dimensions
- Rounded corners
- Theme-aware colors
- Continuous loop animation
- Lightweight

---

## 8. Premium FAB 🎯

**Purpose**: Floating action button with optional extended label

**Usage**:
```dart
PremiumFAB(
  icon: Icons.add,
  label: 'নতুন দান',
  onPressed: () => navigateToDonation(),
  backgroundColor: GramBaseeColors.primary,
)
```

**Features**:
- Extended with label option
- Custom background color
- No elevation (flat design)
- Rounded square shape (16px)
- Icon + label support
- Dark/light mode support

---

## 9. Empty State 🏜️

**Purpose**: Beautiful empty state with icon and CTA

**Usage**:
```dart
EmptyState(
  title: 'কোন দান নেই',
  description: 'এখনো কোন দান নেই। শুরু করতে পারেন।',
  icon: Icons.inbox_outlined,
  actionLabel: 'প্রথম দান করুন',
  onAction: () => navigateToDonation(),
)
```

**Features**:
- Large centered icon with background
- Title and description
- Optional action button
- Centered layout
- All padding included
- Dark/light mode support

---

## 10. Premium Dialog 📱

**Purpose**: Modern modal dialog with dual actions

**Usage**:
```dart
showDialog(
  context: context,
  builder: (context) => PremiumDialog(
    title: 'দান নিশ্চিত করুন?',
    message: '৳२५,००० টাকা দান করতে চান?',
    confirmLabel: 'নিশ্চিত করুন',
    cancelLabel: 'বাতিল করুন',
    onConfirm: () => processDonation(),
    onCancel: () => Navigator.pop(context),
  ),
)
```

**Features**:
- Custom title and message
- Dual action buttons
- Confirm/Cancel callbacks
- Modal styling
- Premium card design
- Elevated shadow
- Dark/light mode support

---

## 11. Citizen Card 👤

**Purpose**: Member profile card with verification badge

**Usage**:
```dart
CitizenCard(
  name: 'রহিম সাহেব',
  role: 'ग्राम प्रधान',
  imageUrl: 'https://...',
  badge: '⭐',
  onTap: () => navigateToCitizenProfile(),
)
```

**Features**:
- Circular profile image (placeholder support)
- Name and role text
- Optional verification badge
- Tap callback
- Column layout
- Dark/light mode support
- Stack-based badge positioning

---

## 📐 Layout Patterns

### Grid Layout
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

### List Layout
```dart
ListView.builder(
  padding: const EdgeInsets.all(GramBaseeSpacing.lg),
  itemCount: items.length,
  itemBuilder: (context, index) => TimelineItem(...),
)
```

### Sliver Layout
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(...),
    SliverPadding(...),
    SliverGrid(...),
    SliverList(...),
  ],
)
```

---

## 🎨 Styling Patterns

### Background Colors
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark 
  ? GramBaseeColors.backgroundDark 
  : GramBaseeColors.backgroundLight;
```

### Text Colors
```dart
Text(
  'Your text',
  style: GramBaseeTypography.bodyLarge(isDark: isDark).copyWith(
    color: isDark 
      ? GramBaseeColors.textPrimaryDark 
      : GramBaseeColors.textPrimary,
  ),
)
```

### Shadows
```dart
Container(
  decoration: BoxDecoration(
    boxShadow: isDark 
      ? GramBaseeShadows.softShadowDark 
      : GramBaseeShadows.softShadow,
  ),
)
```

---

## 🧩 Composition Examples

### KPI Row
```dart
Row(
  children: [
    Expanded(child: KPICard(...)),
    const SizedBox(width: GramBaseeSpacing.lg),
    Expanded(child: KPICard(...)),
  ],
)
```

### Status Row
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: statuses.map((status) =>
      Padding(
        padding: const EdgeInsets.only(right: GramBaseeSpacing.md),
        child: StatusChip(label: status),
      ),
    ).toList(),
  ),
)
```

### Card with List
```dart
Container(
  padding: const EdgeInsets.all(GramBaseeSpacing.lg),
  decoration: BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(GramBaseeBorderRadius.card),
    boxShadow: shadows,
  ),
  child: Column(
    children: [
      TimelineItem(...),
      const Divider(),
      TimelineItem(...),
    ],
  ),
)
```

---

## ✨ Interactive Patterns

### Loading State
```dart
isLoading
  ? ShimmerLoading(height: 24)
  : Text('Content')
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

### Confirmation Dialog
```dart
onDelete: () {
  showDialog(
    context: context,
    builder: (_) => PremiumDialog(
      title: 'Delete?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      onConfirm: performDelete,
    ),
  )
}
```

---

## 🎬 Animation Patterns

### Button Loading
```dart
PremiumButton(
  label: isLoading ? '' : 'Submit',
  isLoading: isLoading,
  onPressed: () => setState(() => isLoading = true),
)
```

### Shimmer Loading
```dart
shimmerController.forward();
// Auto-loops in animation setup
```

---

## 🔄 Responsive Patterns

### Adaptive Layout
```dart
return width > 600
  ? GridView.count(crossAxisCount: 3)
  : GridView.count(crossAxisCount: 2)
```

### Safe Padding
```dart
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: GramBaseeSpacing.lg,
    vertical: GramBaseeSpacing.xl,
  ),
  child: child,
)
```

---

## 📝 Component Checklist

When creating components:
- ✅ Support dark/light mode
- ✅ Use theme tokens (not hardcoded values)
- ✅ Add proper padding/spacing
- ✅ Include shadow on elevation
- ✅ Provide customization options
- ✅ Handle loading states
- ✅ Add accessibility labels
- ✅ Document with examples

---

## 🎓 Best Practices

1. **Always use tokens**
   ```dart
   GramBaseeSpacing.lg     // ✅ Good
   16.0                    // ❌ Avoid
   ```

2. **Theme-aware colors**
   ```dart
   isDark ? darkColor : lightColor  // ✅ Good
   Color(0xFF000000)                // ❌ Avoid
   ```

3. **Reuse components**
   ```dart
   KPICard(...)            // ✅ Good
   CustomCard(...)         // ❌ Create new
   ```

4. **Consistent spacing**
   ```dart
   EdgeInsets.symmetric(
     horizontal: GramBaseeSpacing.lg,
     vertical: GramBaseeSpacing.md,
   )
   ```

---

**Created for গ্রামবাসী (Grambasee) Component Library**

Beautiful, Reusable, Production-Ready UI Components ✨

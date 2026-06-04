# গ্রামবাসী - Premium Flutter Design System

## 📱 Overview

A comprehensive, production-ready design system for **গ্রামবাসী** (Grambasee), a premium modern Flutter community management application. Built with premium design principles inspired by Linear, CRED, Notion, Stripe Dashboard, Apple Wallet, and Headspace.

---

## 🎨 Design Principles

### Core Values
- **Large Breathing Spaces** - Generous padding and margins for visual clarity
- **Soft Shadows** - Subtle, elegant shadows (no harsh borders)
- **Minimal Design** - Clean, clutter-free interfaces
- **Premium Feel** - SaaS-quality fintech aesthetic
- **Accessibility First** - WCAG 2.2 compliant contrast ratios
- **Mobile-First** - Optimized for touch and small screens
- **Smooth Animations** - Delightful transitions and interactions

---

## 🎯 Color System

### Primary Colors
- **Primary**: `#22C55E` (Green) - Main brand color
- **Primary Light**: `#4ECE71` - Hover/Active states
- **Primary Dark**: `#16A34A` - Darker emphasis

### Light Theme Neutrals
- **Background**: `#FFFFFF`
- **Surface**: `#FAFAFA`
- **Card**: `#FBFBFB`
- **Border**: `#F0F0F0`
- **Text Primary**: `#000000`
- **Text Secondary**: `#64748B`
- **Text Tertiary**: `#94A3B8`

### Dark Theme Neutrals
- **Background**: `#1A1A1A`
- **Surface**: `#0F0F0F`
- **Card**: `#242424`
- **Border**: `#363636`
- **Text Primary**: `#FAFAFA`
- **Text Secondary**: `#BCBCBC`
- **Text Tertiary**: `#888888`

### Semantic Colors
- **Success**: `#22C55E` (Green)
- **Warning**: `#F59E0B` (Amber)
- **Error**: `#EF4444` (Red)
- **Info**: `#3B82F6` (Blue)

---

## 📏 Spacing System

| Token | Size | Usage |
|-------|------|-------|
| **xs** | 4px | Micro spaces, between inline elements |
| **sm** | 8px | Small gaps |
| **md** | 12px | Standard micro spacing |
| **lg** | 16px | Standard spacing (most common) |
| **xl** | 24px | Large spacing between sections |
| **xxl** | 32px | Major section spacing |
| **xxxl** | 48px | Page/screen spacing |

---

## 🔘 Border Radius

| Token | Size | Usage |
|-------|------|-------|
| **small** | 8px | Buttons, small components |
| **medium** | 12px | Mid-level components |
| **button** | 16px | All buttons and inputs |
| **card** | 24px | Cards, large containers |
| **full** | 999px | Fully rounded (chips, badges) |

---

## ✍️ Typography

### Fonts
- **Display/Heading**: Hind Siliguri (Bengali, modern, bold)
- **Body/Label**: Noto Sans Bengali (readable, accessible)

### Type Scale

#### Display
- **Display Large**: 40px, 700 weight - Hero headings
- **Display Medium**: 32px, 700 weight - Large page titles
- **Display Small**: 28px, 600 weight - Section titles

#### Heading
- **Heading Large**: 24px, 600 weight - Card titles, sections
- **Heading Medium**: 20px, 600 weight - Subsections
- **Heading Small**: 18px, 600 weight - Component headers

#### Body
- **Body Large**: 16px, 500 weight - Primary content
- **Body Medium**: 14px, 500 weight - Standard body text
- **Body Small**: 12px, 500 weight - Secondary content

#### Label
- **Label Large**: 14px, 600 weight - Button text, form labels
- **Label Medium**: 12px, 600 weight - Chip labels
- **Label Small**: 11px, 600 weight - Badges, captions

#### Caption
- **Caption**: 13px, 400 weight - Meta information, timestamps

---

## 🎭 Shadows

### Soft Shadow
```
offset: (0, 2)
blur: 8px
```
- Used for elevated cards, subtle depth

### Medium Shadow
```
offset: (0, 4)
blur: 16px
```
- Used for modal cards, floating elements

### Elevated Shadow
```
offset: (0, 8)
blur: 24px
```
- Used for modals, dialogs, important overlays

---

## 🧩 Component Library

### 1. **KPI Card**
Displays key metrics with icons and optional subtitles.
```dart
KPICard(
  label: 'মোট দান',
  value: '৳৫,२५,०००',
  subtitle: '+२५% এই মাসে',
  icon: Icons.volunteer_activism,
  isLoading: false,
)
```

### 2. **Status Chip**
Compact status indicators with optional icons.
```dart
StatusChip(
  label: 'চলমান',
  backgroundColor: Colors.orange.withOpacity(0.1),
  textColor: Colors.orange,
  icon: Icons.schedule,
)
```

### 3. **Premium Button**
High-quality button with primary/secondary variants and loading states.
```dart
PremiumButton(
  label: 'নতুন দান',
  onPressed: () {},
  variant: ButtonVariant.primary,
  size: ButtonSize.large,
)
```

### 4. **Search Bar**
Premium search input with smooth animations.
```dart
PremiumSearchBar(
  placeholder: 'গ্রাম অনুসন্ধান করুন...',
  onChanged: (value) {},
)
```

### 5. **Progress Ring**
Circular progress indicator with label and percentage.
```dart
ProgressRing(
  progress: 0.65,
  label: 'প্রকল্প সম্পূর্ণতা',
  value: '65%',
)
```

### 6. **Timeline Item**
Activity/history feed item with icon and timestamp.
```dart
TimelineItem(
  title: 'নতুন দান গৃহীত',
  description: 'রহিম সাহেব ৳२५,०००',
  timestamp: DateTime.now(),
  icon: Icons.volunteer_activism,
)
```

### 7. **Shimmer Loading**
Smooth skeleton loader for async content.
```dart
ShimmerLoading(
  height: 24,
  width: 80,
  borderRadius: GramBaseeBorderRadius.button,
)
```

### 8. **Premium FAB**
Floating action button with extended label support.
```dart
PremiumFAB(
  icon: Icons.add,
  label: 'नয़ा दान',
  onPressed: () {},
)
```

### 9. **Empty State**
Beautiful empty state with icon, title, and CTA.
```dart
EmptyState(
  title: 'कोई डेटा नहीं',
  description: 'अभी कुछ नहीं है',
  icon: Icons.inbox,
  actionLabel: 'शुरुआत करें',
  onAction: () {},
)
```

### 10. **Premium Dialog**
Modern modal dialog with dual actions.
```dart
PremiumDialog(
  title: 'शीर्षक',
  message: 'संदेश',
  confirmLabel: 'पुष्टि करें',
  cancelLabel: 'रद्द करें',
  onConfirm: () {},
)
```

### 11. **Citizen Card**
Profile card for community members with verification badge.
```dart
CitizenCard(
  name: 'रहिम साहेब',
  role: 'ग्राम प्रधान',
  badge: '⭐',
  onTap: () {},
)
```

---

## 📱 Screen Architecture

### 15 Main Screens

1. **Home Dashboard** - Community overview with KPIs and activities
2. **Donation Management** - Donation history and verification
3. **Community Fund** - Fund summary and expense breakdown
4. **Problem Reporting** - Issue tracking and resolution status
5. **Problem Details** - Detailed problem view with timeline
6. **Citizen Directory** - Member search and filtering
7. **Citizen Profile** - Individual member information
8. **Projects** - Community project management
9. **Community Leaders** - Leadership team directory
10. **Notifications** - Alert center with filtering
11. **Activity Feed** - Timeline of all community activities
12. **User Profile** - Personal account settings
13. **Settings** - App preferences and configuration
14. **Authentication** - Login/signup flow
15. **Donation Checkout** - Payment flow with amount selection

---

## 🎬 Animation Specifications

### Transitions
- **Fast**: 200ms - Button taps, state changes
- **Standard**: 300ms - Screen transitions
- **Slow**: 500ms - Complex animations

### Easing Curves
- **Entrance**: `easeOut` - Content appearing
- **Exit**: `easeIn` - Content leaving
- **Continuous**: `easeInOut` - Loops, states

### Microinteractions
- Smooth button tap ripple effect
- Subtle card elevation on hover
- Shimmer loading animation
- Smooth progress updates
- Delightful empty state illustrations

---

## 🌓 Dark & Light Mode

### Implementation
Both themes use identical design language:
- Same spacing and sizing
- Same component behavior
- Same typography hierarchy
- Only color changes based on theme

### Switch Mechanism
```dart
Theme.of(context).brightness == Brightness.dark
```

All components automatically adapt using theme-aware colors.

---

## 📐 Responsive Design

### Breakpoints
- **Mobile**: 0px - 599px
- **Tablet**: 600px - 1199px
- **Desktop**: 1200px+

### Strategy
- Mobile-first design approach
- Single column layouts on mobile
- Grid layouts scale naturally
- Padding increases on larger screens

---

## ♿ Accessibility

### WCAG 2.2 Compliance
- **Contrast Ratio**: Minimum 4.5:1 for text
- **Touch Targets**: Minimum 48x48dp
- **Font Sizes**: Minimum 14px for body text
- **Color Not Alone**: Status conveyed with icons + color

### Features
- Semantic HTML structure
- Proper heading hierarchy
- Alt text for images/icons
- Keyboard navigation support
- Screen reader friendly

---

## 🚀 Performance

### Optimization Strategies
- Lazy loading for lists
- Image caching and compression
- Smooth 60fps animations
- Minimal rebuilds using const constructors
- Efficient state management

---

## 📚 Usage Guide

### Import the Design System
```dart
import 'package:doulatpara/design_system/index.dart';
```

### Apply Theme
```dart
MaterialApp(
  theme: GramBaseeTheme.lightTheme(),
  darkTheme: GramBaseeTheme.darkTheme(),
  themeMode: ThemeMode.system,
)
```

### Use Components
```dart
KPICard(
  label: 'মোট দান',
  value: '৳৫,२५,०००',
  icon: Icons.volunteer_activism,
)
```

---

## 🎨 Design Tools & Files

- Figma File: [Link to design]
- Component Library: Fully documented
- Style Guide: Available in codebase
- Brand Assets: Included in repo

---

## 📝 Customization

### Extending Components
All components are designed to be extended:
```dart
class CustomKPICard extends KPICard {
  // Your customizations
}
```

### Theme Customization
Modify `GramBaseeTheme` and `GramBaseeColors`:
```dart
class CustomTheme extends GramBaseeTheme {
  // Your custom theme
}
```

---

## 📱 Screens Included

### Premium Screens
- ✅ Home Dashboard
- ✅ Donation Management
- ✅ Community Fund
- ✅ Problem Reporting
- ✅ Problem Details
- ✅ Citizen Directory
- ✅ Citizen Profile
- ✅ Projects
- ✅ Community Leaders
- ✅ Notifications
- ✅ Activity Feed
- ✅ User Profile
- ✅ Settings
- ✅ Authentication
- ✅ Donation Checkout

### Navigation
- ✅ Bottom Navigation Bar (5 main tabs)
- ✅ Modular screen architecture
- ✅ Smooth transitions

---

## 🔧 Development

### Setup
1. Add design system imports
2. Apply theme to MaterialApp
3. Use pre-built components
4. Customize as needed

### File Structure
```
lib/
├── design_system/
│   ├── theme.dart          # Colors, typography, theme
│   ├── components.dart     # Reusable components
│   └── index.dart          # Exports
├── premium_screens/
│   ├── home_dashboard_screen.dart
│   ├── donation_management_screen.dart
│   ├── [other screens]
│   ├── main_navigation_screen.dart
│   └── index.dart          # Exports
```

---

## 🎯 Best Practices

1. **Always use design tokens** - Never hardcode colors/spacing
2. **Leverage components** - Build with existing components
3. **Maintain consistency** - Use established patterns
4. **Accessibility first** - Check contrast and labels
5. **Test both themes** - Ensure dark/light parity
6. **Optimize performance** - Use const constructors
7. **Document changes** - Update this guide

---

## 📞 Support

For design system questions, refer to:
- Component source code
- Inline documentation
- This design guide
- Figma design file

---

## 📜 License

This design system is proprietary to গ্রামবাসী (Grambasee).

---

**Created with ❤️ for গ্রামবাসী - Village Community Platform**

# PayChat Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebrand and redesign the village development app into "PayChat" — a premium messaging & P2P payments hybrid with Serene Mint design system.

**Architecture:** Refactor from monolithic `part/part of` to modular screen-per-file structure. Preserve all Firebase data models/services. Layer new features (chat, wallet, marketplace) on top of existing village features. Use Provider for state management.

**Tech Stack:** Flutter 3.x, Firebase (Auth, Firestore, Messaging), Provider, GoRouter, google_fonts, fl_chart, image_picker, intl, shared_preferences, hive_flutter, shimmer, qr_flutter, mobile_scanner

---

## Task 1: Project Scaffolding & Module Restructure

**Files:**
- Modify: `pubspec.yaml` — update name, description, add new deps
- Modify: `lib/main.dart` — app initialization
- Modify: `lib/app.dart` — rebrand to PayChatApp
- Create: `lib/src/` directory structure

**Step 1: Update pubspec.yaml**
- Change name from `doulatpara` to `paychat`
- Update description
- Add dependencies: `provider`, `go_router`, `qr_flutter`, `mobile_scanner`, `flutter_secure_storage`
- Keep existing: cloud_firestore, firebase_auth, firebase_core, firebase_messaging, google_fonts, image_picker, intl, shared_preferences, hive_flutter, shimmer, fl_chart, connectivity_plus, rxdart, url_launcher, http, crypto

**Step 2: Create modular directory structure**
```
lib/
  src/
    core/
      theme/      — AppTheme, colors, typography
      router/     — GoRouter config
      constants/  — App constants
    features/
      auth/       — Login, OTP, profile setup
      chat/       — Conversations, messages, contacts
      wallet/     — Balance, transactions, P2P transfers
      marketplace/— Services, orders
      village/    — Donations, projects, problems (existing)
      home/       — Dashboard
      profile/    — User profile, settings
      notifications/ — Notification center
      splash/     — Splash + onboarding
    shared/
      widgets/    — Reusable UI components
      models/     — Data models
      services/   — Firebase services, connectivity
      utils/      — Helpers, formatters
```

**Step 3: Refactor main.dart**
- Keep Hive init, Firebase init, ConnectivityService init
- Remove part-based architecture
- Initialize Provider scopes

**Step 4: Refactor app.dart**
- Rename `VillageDevelopmentApp` to `PayChatApp`
- Update MaterialApp title to "PayChat"
- Use GoRouter with navigatorKey
- Keep accessibility builder

**Step 5: Create GoRouter config**
- Routes: `/splash`, `/onboarding`, `/login`, `/setup`, `/home`, `/chat`, `/chat/:id`, `/wallet`, `/wallet/send`, `/wallet/request`, `/marketplace`, `/village/donations`, `/village/projects`, `/village/problems`, `/notifications`, `/profile`, `/settings`

---

## Task 2: Serene Mint Design System

**Files:**
- Create: `lib/src/core/theme/app_colors.dart`
- Create: `lib/src/core/theme/app_typography.dart`
- Create: `lib/src/core/theme/app_theme.dart`
- Create: `lib/src/core/theme/app_spacing.dart`
- Delete: `lib/core/theme/app_theme.dart` (old)
- Modify: `lib/app.dart` — use new theme

**Step 1: Define AppColors (Serene Mint palette)**

Primary Gradient: `#2D5A47` → `#4CAF50`
- primaryBase: `#2D5A47` (Deep Forest)
- primaryLight: `#4CAF50` (Emerald)
- primaryMint: `#81C784` (Soft Mint)
- primarySurface: `#E8F5E9` (Mint White)

Background & Surfaces:
- background: `#F7FAF8` (Mint White)
- surface: `#FFFFFF`
- surfaceVariant: `#F1F8E9` (Very light mint)
- cardBg: `#FFFFFF`

Text:
- textPrimary: `#1B3A2D` (Deep Forest)
- textSecondary: `#4A6B5C` (Sage)
- textMuted: `#8DA69A` (Muted Sage)
- textOnPrimary: `#FFFFFF`
- textOnDark: `#F7FAF8`

Accent/Semantic:
- accent: `#4CAF50` (Emerald)
- success: `#2E7D32` (Green)
- warning: `#F9A825` (Amber)
- error: `#D32F2F` (Terracotta Red) — for negative transactions
- info: `#1976D2` (Blue)

Borders & Dividers:
- border: `#E0E8E3`
- borderLight: `#EFF3F0`

Gradients:
- primaryGradient: LinearGradient(`#2D5A47` → `#4CAF50`)
- cardGradient: LinearGradient(`#FFFFFF` → `#F7FAF8`)

**Step 2: Define AppTypography**
- Headers: Rajdhani (google_fonts.rajdhani) — bold, uppercase feel
- Body: Inter (google_fonts.inter) — clean, readable
- Financials/OTP: JetBrains Mono (google_fonts.jetBrainsMono) — monospace for numbers
- Full 14-step text theme (displayLarge → labelSmall)

**Step 3: Build AppTheme**
- Light theme with Serene Mint colors
- Dark theme with deep forest variant
- Glassmorphism card decorations (subtle backdrop blur + light mint tint)
- Soft shadow presets (small, medium, large)
- Animation durations (200ms default, 300ms for sheets)

**Step 4: Define Spacing & Radius constants**
- Spacing: xs(4), sm(8), md(12), lg(16), xl(20), xxl(24), x3(32), x4(48)
- Radius: sm(8), md(12), lg(16), xl(24), pill(999)
- Card elevation presets: none, subtle, raised

---

## Task 3: Shared Widget Library

**Files:**
- Create: `lib/src/shared/widgets/glass_card.dart` — glassmorphism card
- Create: `lib/src/shared/widgets/gradient_button.dart`
- Create: `lib/src/shared/widgets/mint_chip.dart` — category/badge chips
- Create: `lib/src/shared/widgets/balance_display.dart` — wallet balance widget
- Create: `lib/src/shared/widgets/avatar_widget.dart` — user avatar with online dot
- Create: `lib/src/shared/widgets/loading_shimmer.dart`
- Create: `lib/src/shared/widgets/empty_state.dart`
- Create: `lib/src/shared/widgets/pin_input.dart` — 4-digit PIN input
- Create: `lib/src/shared/widgets/transaction_tile.dart` — transaction list tile
- Create: `lib/src/shared/widgets/search_bar.dart` — custom search field
- Create: `lib/src/shared/widgets/section_header.dart` — "See All" header

---

## Task 4: Splash & Onboarding Rebrand

**Files:**
- Create: `lib/src/features/splash/splash_screen.dart`
- Create: `lib/src/features/splash/onboarding_screen.dart`
- Modify: `lib/src/core/router/router.dart` — add splash/onboarding routes
- Delete: `lib/splash_screen.dart`
- Delete: `lib/onboarding_screen.dart`

**Splash Screen:**
- PayChat logo (chat bubble + currency icon combo)
- Animated reveal with Serene Mint colors
- Gradient background
- Auto-navigate to onboarding (first run) or home

**Onboarding (3 pages):**
1. "Premium Messaging" — chat features, media sharing
2. "P2P Payments" — send/request money securely
3. "Service Marketplace" — buy/sell services in-chat
4. (Optional) Notification permission request

---

## Task 5: Authentication Rebrand

**Files:**
- Create: `lib/src/features/auth/login_screen.dart`
- Create: `lib/src/features/auth/otp_screen.dart`
- Create: `lib/src/features/auth/profile_setup_screen.dart`
- Delete: `lib/screens/auth_screens.dart` (old)
- Modify: `lib/src/core/router/router.dart` — add auth routes

**Flow:**
1. Phone number input → OTP verification screen
2. Google Sign-In option (existing firebase_auth + google_sign_in)
3. Profile setup: name, email, avatar, phone (for payment identity)

**Preserve from old:**
- Firebase phone auth flow
- Google Sign-In integration
- Profile setup form fields (profession, village, etc.)
- Theme-mode persistence

---

## Task 6: Home Dashboard (PayChat Style)

**Files:**
- Create: `lib/src/features/home/home_screen.dart`
- Create: `lib/src/features/home/widgets/balance_card.dart` — hero wallet card
- Create: `lib/src/features/home/widgets/quick_actions.dart` — Send/Request/Pay/Marketplace
- Create: `lib/src/features/home/widgets/recent_transactions.dart`
- Create: `lib/src/features/home/widgets/village_insights.dart` — mini village stats
- Delete: `lib/screens/root_shell.dart` (rebuilt)
- Delete: `lib/screens/home_screen.dart` (rebuilt)

**Home Screen Layout:**
```
[PayChat Header] — notifications bell, settings
[Balance Card] — glass card with gradient, total balance, "Add Money" button
[Quick Actions] — 4-tile grid: Send, Request, Pay, Marketplace
[Recent Transactions] — horizontal scroll list
[Village Insights] — mini section for existing village features 
  [Donations] [Projects] [Problems] → taps go to Village section
[Bottom Nav] — Home, Chat, Wallet, Marketplace, Profile
```

**Bottom Navigation:**
- 5 tabs with labels and icons
- Active: primary gradient indicator
- Custom curved-notch nav bar (serene mint style)

---

## Task 7: Messaging & Chat System

**Files:**
- Create: `lib/src/features/chat/chat_list_screen.dart`
- Create: `lib/src/features/chat/conversation_screen.dart`
- Create: `lib/src/features/chat/contacts_screen.dart`
- Create: `lib/src/features/chat/widgets/message_bubble.dart`
- Create: `lib/src/features/chat/widgets/chat_tile.dart`
- Create: `lib/src/features/chat/widgets/contact_tile.dart`
- Create: `lib/src/features/chat/widgets/message_input.dart`
- Create: `lib/src/features/chat/widgets/media_picker.dart`
- Create: `lib/src/features/chat/widgets/service_card.dart` — in-chat service card
- Create: `lib/src/features/chat/services/chat_service.dart`
- Create: `lib/src/features/chat/models/chat_models.dart`

**Chat Models:**
```dart
ChatConversation { id, participants[], lastMessage, lastMessageTime, unreadCount }
ChatMessage { id, conversationId, senderId, text, type(text/image/file/service), mediaUrl, timestamp, status(sent/delivered/read) }
Contact { id, userId, name, avatar, phone, isRegistered }
```

**Chat Service:**
- Firestore collection: `conversations/{id}/messages/{id}`
- StreamBuilder for real-time messages
- Typing indicator support
- Message status tracking
- Image/file sharing via image_picker + Firebase Storage

**In-Chat Service Card:**
- Embedded widget in message flow
- Shows service title, price, seller
- "Order Now" button → opens order bottom sheet

---

## Task 8: Wallet & P2P Payments

**Files:**
- Create: `lib/src/features/wallet/wallet_screen.dart`
- Create: `lib/src/features/wallet/send_money_screen.dart`
- Create: `lib/src/features/wallet/request_money_screen.dart`
- Create: `lib/src/features/wallet/transaction_history_screen.dart`
- Create: `lib/src/features/wallet/widgets/transaction_tile.dart`
- Create: `lib/src/features/wallet/widgets/pin_verification_sheet.dart`
- Create: `lib/src/features/wallet/services/wallet_service.dart`
- Create: `lib/src/features/wallet/models/wallet_models.dart`

**Wallet Models:**
```dart
Wallet { userId, balance, currency }
Transaction { id, senderId, receiverId, amount, type(send/request/payment), status(pending/completed/rejected), note, createdAt }
PaymentMethod { id, type(bKash/Nagad/Bank/Card), number, name, isDefault }
```

**Wallet Features:**
- Balance display with gradient card
- Quick actions: Send, Request, Add Money
- Transaction history with filters (All/Sent/Received/Pending)
- 4-digit PIN verification for all outgoing transactions
- Biometric shortcut (local_auth)
- In-chat payment: when viewing a conversation, tap "+" → "Send Money"

**PIN Flow:**
1. User taps "Send Money"
2. Enter amount → Select contact
3. PIN modal slides up (glassmorphism bottom sheet)
4. 4-digit PIN input (JetBrains Mono, large digits)
5. On success: transaction created in Firestore, push notification sent to receiver

---

## Task 9: Service Marketplace

**Files:**
- Create: `lib/src/features/marketplace/marketplace_screen.dart`
- Create: `lib/src/features/marketplace/my_services_screen.dart`
- Create: `lib/src/features/marketplace/create_service_screen.dart`
- Create: `lib/src/features/marketplace/order_detail_screen.dart`
- Create: `lib/src/features/marketplace/widgets/service_card.dart`
- Create: `lib/src/features/marketplace/widgets/order_bottom_sheet.dart`
- Create: `lib/src/features/marketplace/services/marketplace_service.dart`
- Create: `lib/src/features/marketplace/models/marketplace_models.dart`

**Marketplace Models:**
```dart
Service { id, sellerId, title, description, price, category, images[], isActive }
ServiceOrder { id, serviceId, buyerId, sellerId, amount, status(pending/accepted/rejected/completed), message, createdAt }
ServiceCategory { id, name, icon, color }
```

**Marketplace Features:**
- Browse services grid/list
- Filter by category
- Search services
- My Services (seller view): list, create, edit, toggle active
- Order management: incoming orders with Accept/Reject
- Service creation form: title, description, price, category, images

---

## Task 10: Village Features Integration (Keep Existing)

**Files:**
- Create: `lib/src/features/village/village_hub_screen.dart`
- Create: `lib/src/features/village/donations_screen.dart`
- Create: `lib/src/features/village/projects_screen.dart`
- Create: `lib/src/features/village/problems_screen.dart`
- Create: `lib/src/features/village/leaderboard_screen.dart`
- Create: `lib/src/features/village/citizens_screen.dart`
- Delete: `lib/screens/village_fund_screen.dart`
- Delete: `lib/screens/donate_screen.dart`
- Delete: `lib/screens/projects_screen.dart`
- Delete: `lib/screens/problems_screen.dart`
- Delete: `lib/screens/citizens_page.dart`
- Delete: `lib/screens/leaderboard_page.dart`
- Delete: `lib/screens/admin_panel_screen.dart`
- Delete: `lib/screens/profile_screen.dart`
- Delete: `lib/screens/notification_screen.dart`
- Delete: `lib/screens/ui_helpers.dart`
- Delete: `lib/screens/more_helpers.dart`

**Migration approach:**
- Extract screen logic from `part` files into proper feature modules
- Apply Serene Mint theme tokens (replace old `AppColors` references)
- Reuse existing `DataService` methods (donations, projects, problems, citizens)
- Keep all Firebase integration intact
- Preserve existing models — wrap in new feature-level models if needed

**Village Hub:**
- Dashboard with summary cards (Total Fund, Spent, Balance, Projects)
- Quick links to Donate, Projects, Problems, Citizens, Leaderboard
- Accessible from bottom nav or home screen village widget

---

## Task 11: Profile & Settings

**Files:**
- Create: `lib/src/features/profile/profile_screen.dart`
- Create: `lib/src/features/profile/settings_screen.dart`
- Create: `lib/src/features/profile/edit_profile_screen.dart`
- Create: `lib/src/features/profile/change_number_screen.dart`
- Create: `lib/src/features/profile/widgets/profile_header.dart`
- Delete: `lib/screens/profile_screen.dart` (old)

**Profile Features:**
- Avatar, name, phone, email
- Wallet balance shortcut
- My Services link
- Payment methods management
- Security: Change PIN, Change Number (2-step verification)
- Settings: Theme toggle, Language, Notifications, Accessibility
- Logout

**Change Number Flow:**
1. Step 1: Verify current number (OTP)
2. Step 2: Enter new number
3. Step 3: Verify new number (OTP)
4. Migrate account data to new number

---

## Task 12: Notifications Center

**Files:**
- Create: `lib/src/features/notifications/notification_screen.dart`
- Create: `lib/src/features/notifications/widgets/notification_tile.dart`
- Delete: `lib/screens/notification_screen.dart` (old)

**Features:**
- Transaction notifications (payment received, request, accepted)
- Chat notifications (new message)
- Marketplace notifications (new order, order update)
- Village notifications (donation approved, problem update)
- Filter: All / Unread / Read
- Mark as read / Mark all read
- Deep-link navigation on tap

---

## Task 13: Data Service Layer Migration

**Files:**
- Create: `lib/src/shared/services/data_service.dart` (enhanced version)
- Modify: Keep existing `lib/data_service.dart` during transition
- Modify: `lib/src/shared/models/` — model files

**Keep existing services:**
- `DataService` — all village data streams
- `ConnectivityService` — online/offline
- `PushNotificationService` — FCM handling

**Add new services:**
- `WalletService` — wallet balance, transactions, PIN management
- `ChatService` — conversations, messages, real-time subscriptions
- `MarketplaceService` — services CRUD, orders

**Service Architecture:**
```dart
class WalletService {
  final FirebaseFirestore _db;
  final String _userId;
  
  Stream<Wallet> getWallet();
  Future<void> sendMoney(String toUserId, double amount, String pin);
  Future<void> requestMoney(String fromUserId, double amount, String note);
  Stream<List<Transaction>> getTransactions({TransactionFilter? filter});
  Future<bool> verifyPin(String pin);
  Future<void> changePin(String oldPin, String newPin);
}
```

---

## Task 14: Provider State Management

**Files:**
- Create: `lib/src/core/providers/providers.dart`
- Create: `lib/src/core/providers/auth_provider.dart`
- Create: `lib/src/core/providers/wallet_provider.dart`
- Create: `lib/src/core/providers/chat_provider.dart`

**Provider Architecture:**
```dart
// Top-level MultiProvider in app.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => WalletProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
  ],
)
```

- Each provider wraps Firebase service calls
- Exposes reactive state via ChangeNotifier
- Screens use `context.watch<XProvider>()` or `context.read<XProvider>()`

---

## Task 15: Cleanup & Migration

**Files:**
- Delete: All old `lib/screens/` files (after migration verified)
- Delete: `lib/screens.dart` (the part file aggregator)
- Delete: `lib/ui/design_system.dart` (replaced by new theme)
- Delete: `lib/ui/components.dart` (replaced by shared widgets)
- Delete: `lib/ui/motion.dart` (migrate motion helpers)
- Modify: `lib/main.dart` — remove old imports
- Verify: `pubspec.yaml` — remove unused deps

**Verification:**
1. App compiles without errors
2. All Firebase features work (donations, projects, problems)
3. New PayChat features work (chat, wallet, marketplace)
4. Theme renders correctly on both light/dark mode
5. Bottom navigation works across all 5 tabs
6. PIN verification flow works end-to-end
7. Splash screen → onboarding → auth → home flow is smooth

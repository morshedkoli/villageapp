# Database Management Scripts

This directory contains Python scripts for managing the Firestore database used by the Village Development App.

## Overview

The app uses **dynamic data from Firebase Firestore** for all domain content. This means:
- ✅ No hardcoded demo data in the app code
- ✅ All configuration is stored in Firestore and can be updated without app changes
- ✅ Payment methods are configured in the database
- ✅ All user content (problems, projects, donations) comes from the database

## Usage

### Prerequisites

1. Install firebase-admin SDK:
```bash
pip install firebase-admin
```

2. Obtain Firebase Admin credentials:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `firebase-admin-key.json`

### Scripts

#### 1. `initialize_database.py` - Initialize Fresh Database

Sets up the database structure with default configuration (payment methods, village document, etc.).

**Use when:**
- Setting up a new Firebase project
- Resetting configuration to defaults
- Setting up for development/testing

```bash
python initialize_database.py path/to/firebase-admin-key.json
```

What it does:
- Creates `config/paymentMethods` with default payment method definitions (bKash, Nagad, Rocket, Bank)
- Creates `villages/main_village` document with zero balances
- Initializes collection indexes
- Shows data structure reference for other collections

**Output example:**
```
Connected to Firebase

--- Initializing Database ---

✓ Payment methods configured
✓ Village document created
✓ Database initialization complete!
```

#### 2. `clear_database.py` - Completely Clear All Data

Removes all user data from Firestore while **preserving admin user accounts**.

**Use when:**
- Clearing out test/demo data
- Starting fresh with a clean database
- Resetting the app for new deployment

```bash
python clear_database.py path/to/firebase-admin-key.json
```

**Important:** 
- ⚠️ This is destructive - backs up important data first!
- ✅ Admin users are automatically preserved
- All collections will be cleared except admin data

What it does:
- Identifies all admin user accounts
- Removes all documents from: notifications, fund_transactions, projects, problems, donations, users (except admins)
- Clears subcollections (notification_reads, votes, etc.) except for admins
- Resets village document counts to zero but preserves payment account configuration

**Output example:**
```
--- Identifying Admin Users ---
Found admin user: abc123xyz

--- Starting Database Cleanup ---
Cleared collection: notifications (deleted 0 documents)
Cleared collection: fund_transactions (deleted 3 documents)
Cleared collection: projects (deleted 2 documents)
✓ Cleanup complete!
  Total documents deleted: 47
  Admin users preserved: 1
```

## Database Structure

### Collections

The app uses these Firestore collections:

#### `config/`
- `paymentMethods`: Payment method configuration
  ```json
  {
    "methods": [
      {
        "key": "bKash",
        "bn": "বিকাশ",
        "en": "bKash",
        "color": 16719726,
        "icon": "phone_android_rounded",
        "position": 1
      }
    ],
    "lastUpdated": timestamp,
    "version": 1
  }
  ```

#### `villages/`
- `main_village`: Main village document
  ```json
  {
    "name": "Our Village",
    "totalCitizens": 100,
    "totalFundCollected": 50000.0,
    "totalSpent": 30000.0,
    "paymentAccounts": {
      "bKash": {"number": "01712345678", "name": "Mosque Fund"},
      "Bank": {"number": "123-456", "name": "Main Account", "bankName": "..."} 
    },
    "createdAt": timestamp,
    "lastUpdated": timestamp
  }
  ```

#### `users/`
User profiles created on first login
```json
{
  "name": "User Name",
  "email": "user@example.com",
  "photoURL": "https://...",
  "phone": "01712345678",
  "isCitizen": true,
  "isAdmin": false,
  "createdAt": timestamp
}
```

With subcollections:
- `notification_reads/{notificationId}`: Tracks which notifications user has read
- `votes/{problemId}`: User's votes on problems

#### `donations/`
Donation records
```json
{
  "donorName": "John Doe",
  "amount": 5000.0,
  "paymentMethod": "bKash",
  "transactionId": "TRX123",
  "senderNumber": "01712345678",
  "status": "Pending|Approved|Rejected",
  "userId": "firebase-uid",
  "createdAt": timestamp
}
```

#### `problems/`
Community problem reports
```json
{
  "title": "Broken Road",
  "description": "Road has large potholes...",
  "location": "Main Street",
  "photoUrl": "https://...",
  "status": "Reported|In Progress|Resolved",
  "reportedBy": "firebase-uid",
  "reportedByName": "Reporter Name",
  "upvotes": 5,
  "downvotes": 1,
  "createdAt": timestamp
}
```

With subcollection:
- `votes/{userId}`: User's vote (1 for upvote, -1 for downvote)

#### `projects/`
Community development projects
```json
{
  "title": "School Renovation",
  "description": "Renovating the primary school...",
  "status": "Planning|In Progress|Completed",
  "budget": 100000.0,
  "spent": 35000.0,
  "progress": 35,
  "photos": ["url1", "url2"],
  "createdAt": timestamp
}
```

#### `notifications/`
App notifications
```json
{
  "title": "New Donation",
  "message": "Received 5000 BDT donation",
  "type": "success|info|warning|error",
  "link": "/fund",
  "createdAt": timestamp
}
```

## App Integration

The Flutter app automatically:
1. ✅ Fetches all data from Firestore collections via `DataService`
2. ✅ Streams real-time updates using `StreamBuilder`
3. ✅ Displays dynamic payment methods from `config/paymentMethods`
4. ✅ Shows dynamic problem count in sidebar badge
5. ✅ Supports offline mode with automatic sync
6. ✅ Validates all writes with Firestore rules

### Key Data Service Methods

```dart
// Fetch payment methods (auto-fallback to defaults if not in DB)
DataService.instance.paymentMethods()

// Get pending problems count for UI badge
DataService.instance.pendingProblemsCount()

// Get all donations
DataService.instance.donations()

// Get all problems
DataService.instance.problems()

// And many more...
```

## Workflow

### First Setup
1. Initialize Firebase project with Firestore
2. Create admin user and set `admin: true` in their profile
3. Run `initialize_database.py` to set up configuration
4. Configure payment accounts via admin panel
5. Users can now register and start using the app

### Regular Database Cleanup
1. Backup important data if needed
2. Run `clear_database.py` to remove test data (preserves admins)
3. Data is now fresh for new testing

### Updating Configuration
Edit directly in Firebase Console or:
1. Export config documents
2. Modify as needed
3. Re-import/update via Cloud Firestore UI

## Firestore Security Rules

All collections are protected by rules defined in `firestore.rules`:
- Public collections (donations, problems, projects, notifications) are readable by all
- Users can only create/update their own data
- Admin panel operations require `admin: true` claim
- Validation rules prevent invalid data

## Notes

- All data uses **server timestamps** for consistency across devices
- Payment account associations are stored as a map in the village document
- Real-time updates use Firestore listeners (no polling)
- Offline changes are queued and synced when connectivity returns
- Admin users are identified by `admin: true` custom claim or user document flag

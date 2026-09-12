# Al-Islah Village Android App

Native Android application for the Al-Islah village management platform, built using Jetpack Compose and Firebase.

## Setup & Build Instructions

### 1. Prerequisites
- Android Studio Ladybug (2024.2.1) or newer
- JDK 17 or higher
- Android SDK 34 (Android 14)

### 2. Firebase Configuration
Firebase configuration (`google-services.json`) is omitted from version control for security.

1. Obtain `google-services.json` from the Firebase Console for project `village-1a6d9` (package `com.murshedkoli.alislah`).
2. Place it in the `app/` directory:
   ```bash
   cp app/google-services.json.example app/google-services.json
   ```
   (and update with your project credentials).

### 3. Signing Key (Debug)
The debug keystore (`app/debug.keystore`) is tracked in the repository with standard password `android`. This ensures that all development clones share the same SHA-1 certificate fingerprint (`11:F4:E5:7D:7F:AD:CF:A5:F2:43:14:B3:3F:BD:D3:0B:23:54:91:1E`) registered for Firebase Google Sign-In.

### 4. Building the Project
From the repository root or `android-native` folder:
```powershell
.\gradlew.bat assembleDebug
```
or to run unit tests:
```powershell
.\gradlew.bat test
```

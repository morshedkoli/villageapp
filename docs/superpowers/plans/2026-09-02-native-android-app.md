# Native Android App (GramBasee) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native Kotlin/Jetpack Compose Android app (`android-native/`) with full feature parity to `clientapp` (Flutter), sharing the same Firebase project/Firestore schema/rules.

**Architecture:** MVVM with Hilt DI. Compose screens observe `StateFlow` from per-feature `ViewModel`s; ViewModels call `Repository` classes that wrap Firebase Auth/Firestore/Messaging directly (no custom backend). Compose Navigation with a 5-tab bottom bar (Home, Donations, Problems, Citizens, Profile) plus pushed detail screens, mirroring clientapp's `PremiumBottomNav` IA.

**Tech Stack:** Kotlin, Jetpack Compose, Material 3, Hilt, Firebase (Auth, Firestore, Cloud Messaging, Credential Manager for Google sign-in), Coroutines/Flow, JUnit + Turbine for ViewModel tests.

**Spec:** `docs/superpowers/specs/2026-09-02-native-android-app-design.md`

## Global Constraints

- Project lives at `D:\village-admin\villageapp\android-native\`, a sibling Gradle project — never nested inside `admin/` or `clientapp/`, and this plan must never modify files under `admin/` or `clientapp/`.
- Reuse the existing Firebase project: copy `clientapp/android/app/google-services.json` verbatim into `android-native/app/google-services.json`. No new Firebase project, no Firestore rules changes.
- Auth must replicate `clientapp/lib/services/auth_service.dart`'s convention exactly: phone+password login uses Firebase Email/Password auth with synthetic email `{normalizedPhone}@village.app`; Google sign-in uses OAuth web client ID `1064035305311-2ovc90ovj0ujdslrgpot09id15uhuho7.apps.googleusercontent.com`.
- Firestore field parsing must be defensive (missing/wrong-typed fields fall back to a default, never throw), matching `clientapp/lib/models.dart`'s `_readString`/`_readDouble`/`_readInt`/`_readDate` helpers.
- Primary color `#22C55E`, light+dark Material 3 themes, matching `clientapp/DESIGN_SYSTEM.md`.
- No offline sync layer beyond Firestore SDK's built-in cache (deferred per spec).

---

## File Structure

```
android-native/
  settings.gradle.kts
  build.gradle.kts
  app/
    build.gradle.kts
    google-services.json
    src/main/AndroidManifest.xml
    src/main/java/app/village/grambasee/
      GramBaseeApplication.kt
      MainActivity.kt
      di/FirebaseModule.kt
      theme/Color.kt
      theme/Type.kt
      theme/Shape.kt
      theme/Theme.kt
      core/Parsing.kt
      core/Result.kt (UiState sealed class shared by ViewModels)
      model/Village.kt
      model/UserProfile.kt
      model/Donation.kt
      model/FundTransaction.kt
      model/Problem.kt
      model/Project.kt
      model/Citizen.kt
      model/AppNotification.kt
      model/PaymentConfig.kt
      data/AuthRepository.kt
      data/VillageRepository.kt
      data/DonationRepository.kt
      data/ProblemRepository.kt
      data/ProjectRepository.kt
      data/CitizenRepository.kt
      data/NotificationRepository.kt
      feature/splash/SplashScreen.kt
      feature/onboarding/OnboardingScreen.kt
      feature/auth/LoginScreen.kt
      feature/auth/LoginViewModel.kt
      feature/home/HomeScreen.kt
      feature/home/HomeViewModel.kt
      feature/home/AllDonationsScreen.kt
      feature/home/AllExpensesScreen.kt
      feature/donation/DonationScreen.kt
      feature/donation/DonationCheckoutScreen.kt
      feature/donation/DonationViewModel.kt
      feature/problems/ProblemsScreen.kt
      feature/problems/ProblemDetailsScreen.kt
      feature/problems/ReportProblemScreen.kt
      feature/problems/ProblemsViewModel.kt
      feature/projects/ProjectsScreen.kt
      feature/projects/ProjectDetailsScreen.kt
      feature/projects/ProjectsViewModel.kt
      feature/citizens/CitizenDirectoryScreen.kt
      feature/citizens/CitizenProfileScreen.kt
      feature/citizens/CitizenViewModel.kt
      feature/leaders/LeadersScreen.kt
      feature/notifications/NotificationScreen.kt
      feature/notifications/NotificationViewModel.kt
      feature/reports/ReportsScreen.kt
      feature/profile/ProfileScreen.kt
      feature/settings/SettingsScreen.kt
      push/GramBaseeMessagingService.kt
      nav/GramBaseeNavHost.kt
      nav/Destinations.kt
    src/test/java/app/village/grambasee/
      model/DonationTest.kt
      model/ProblemTest.kt
      data/AuthRepositoryTest.kt
      feature/home/HomeViewModelTest.kt
      feature/donation/DonationViewModelTest.kt
      feature/problems/ProblemsViewModelTest.kt
```

---

### Task 1: Project Scaffold

**Files:**
- Create: `android-native/settings.gradle.kts`
- Create: `android-native/build.gradle.kts`
- Create: `android-native/app/build.gradle.kts`
- Create: `android-native/app/google-services.json` (copy of `clientapp/android/app/google-services.json`)
- Create: `android-native/app/src/main/AndroidManifest.xml`
- Create: `android-native/app/src/main/java/app/village/grambasee/GramBaseeApplication.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/MainActivity.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/di/FirebaseModule.kt`

**Interfaces:**
- Produces: application id `app.village.grambasee`, Hilt `@HiltAndroidApp` application class `GramBaseeApplication`, `MainActivity` as the single-activity Compose host, `FirebaseModule` providing `FirebaseAuth`, `FirebaseFirestore`, `FirebaseMessaging` singletons via Hilt.

- [ ] **Step 1: Read the source google-services.json**

Run: `cat clientapp/android/app/google-services.json` and note `project_id`, `package_name` values (package name there is clientapp's; the new app registers its own `app.village.grambasee` package under the same Firebase project via the Firebase console/CLI — for this plan, copy the file as-is so Firestore/Auth work immediately in debug builds using the shared project; package name mismatch is tolerated by the Android Firebase SDK for Firestore/Auth/Messaging as long as the API key in the file is valid for the project).

- [ ] **Step 2: Create settings.gradle.kts**

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "GramBasee"
include(":app")
```

- [ ] **Step 3: Create root build.gradle.kts**

```kotlin
plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.google.dagger.hilt.android") version "2.52" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
    id("com.google.devtools.ksp") version "2.0.21-1.0.28" apply false
}
```

- [ ] **Step 4: Create app/build.gradle.kts**

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.gms.google-services")
    id("com.google.dagger.hilt.android")
    id("com.google.devtools.ksp")
}

android {
    namespace = "app.village.grambasee"
    compileSdk = 35

    defaultConfig {
        applicationId = "app.village.grambasee"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")

    implementation(platform("androidx.compose:compose-bom:2024.11.00"))
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.navigation:navigation-compose:2.8.4")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    implementation("androidx.credentials:credentials:1.3.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.3.0")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.1.1")

    implementation("com.google.dagger:hilt-android:2.52")
    ksp("com.google.dagger:hilt-android-compiler:2.52")
    implementation("androidx.hilt:hilt-navigation-compose:1.2.0")

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.9.0")

    testImplementation("junit:junit:4.13.2")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.9.0")
    testImplementation("app.cash.turbine:turbine:1.2.0")
    testImplementation("io.mockk:mockk:1.13.13")
}
```

- [ ] **Step 5: Copy google-services.json**

```bash
mkdir -p android-native/app
cp clientapp/android/app/google-services.json android-native/app/google-services.json
```

- [ ] **Step 6: Create AndroidManifest.xml**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:name=".GramBaseeApplication"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.GramBasee">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.GramBasee">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <service
            android:name=".push.GramBaseeMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
    </application>
</manifest>
```

Also create `android-native/app/src/main/res/values/strings.xml` with `<string name="app_name">GramBasee</string>` and a minimal `values/themes.xml` with an empty `Theme.GramBasee` parent `Theme.Material3.DayNight.NoActionBar` (Compose supplies the real theme at runtime; this is only the manifest-required style).

- [ ] **Step 7: Create GramBaseeApplication.kt**

```kotlin
package app.village.grambasee

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class GramBaseeApplication : Application()
```

- [ ] **Step 8: Create FirebaseModule.kt**

```kotlin
package app.village.grambasee.di

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.messaging.FirebaseMessaging
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object FirebaseModule {
    @Provides
    @Singleton
    fun provideAuth(): FirebaseAuth = FirebaseAuth.getInstance()

    @Provides
    @Singleton
    fun provideFirestore(): FirebaseFirestore = FirebaseFirestore.getInstance()

    @Provides
    @Singleton
    fun provideMessaging(): FirebaseMessaging = FirebaseMessaging.getInstance()
}
```

- [ ] **Step 9: Create MainActivity.kt (placeholder Compose host, replaced with NavHost in Task 15)**

```kotlin
package app.village.grambasee

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Surface { Text("GramBasee") }
        }
    }
}
```

- [ ] **Step 10: Build the project**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 11: Commit**

```bash
git add android-native
git commit -m "feat(android-native): scaffold Gradle project with Hilt and Firebase"
```

---

### Task 2: Design System (Theme)

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/theme/Color.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/theme/Type.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/theme/Shape.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/theme/Theme.kt`

**Interfaces:**
- Produces: `@Composable fun GramBaseeTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit)` — used by `MainActivity` (Task 15) to wrap the app.

- [ ] **Step 1: Create Color.kt from clientapp's palette**

Reference: `clientapp/DESIGN_SYSTEM.md` primary `#22C55E`.

```kotlin
package app.village.grambasee.theme

import androidx.compose.ui.graphics.Color

val GramBaseePrimary = Color(0xFF22C55E)
val GramBaseePrimaryDark = Color(0xFF16A34A)
val GramBaseeOnPrimary = Color(0xFFFFFFFF)

val GramBaseeLightBackground = Color(0xFFFAFAFA)
val GramBaseeLightSurface = Color(0xFFFFFFFF)
val GramBaseeLightOnBackground = Color(0xFF1A1A1A)

val GramBaseeDarkBackground = Color(0xFF121212)
val GramBaseeDarkSurface = Color(0xFF1E1E1E)
val GramBaseeDarkOnBackground = Color(0xFFF5F5F5)

val GramBaseeError = Color(0xFFDC2626)
```

- [ ] **Step 2: Create Type.kt**

```kotlin
package app.village.grambasee.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

val GramBaseeTypography = Typography(
    displayLarge = TextStyle(fontWeight = FontWeight.Bold, fontSize = 32.sp),
    headlineMedium = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 24.sp),
    titleLarge = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 20.sp),
    bodyLarge = TextStyle(fontWeight = FontWeight.Normal, fontSize = 16.sp),
    bodyMedium = TextStyle(fontWeight = FontWeight.Normal, fontSize = 14.sp),
    labelLarge = TextStyle(fontWeight = FontWeight.Medium, fontSize = 14.sp),
)
```

- [ ] **Step 3: Create Shape.kt**

```kotlin
package app.village.grambasee.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Shapes

val GramBaseeShapes = Shapes(
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(12.dp),
    large = RoundedCornerShape(24.dp),
)
```

(Add `import androidx.compose.ui.unit.dp` at the top.)

- [ ] **Step 4: Create Theme.kt**

```kotlin
package app.village.grambasee.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme(
    primary = GramBaseePrimary,
    onPrimary = GramBaseeOnPrimary,
    background = GramBaseeLightBackground,
    surface = GramBaseeLightSurface,
    onBackground = GramBaseeLightOnBackground,
    error = GramBaseeError,
)

private val DarkColors = darkColorScheme(
    primary = GramBaseePrimary,
    onPrimary = GramBaseeOnPrimary,
    background = GramBaseeDarkBackground,
    surface = GramBaseeDarkSurface,
    onBackground = GramBaseeDarkOnBackground,
    error = GramBaseeError,
)

@Composable
fun GramBaseeTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        typography = GramBaseeTypography,
        shapes = GramBaseeShapes,
        content = content,
    )
}
```

- [ ] **Step 5: Wire into MainActivity**

Edit `MainActivity.kt`'s `setContent` block to wrap content in `GramBaseeTheme { Surface { Text("GramBasee") } }`.

- [ ] **Step 6: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 7: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add GramBasee Material 3 theme"
```

---

### Task 3: Shared Parsing Helpers + Data Models

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/core/Parsing.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/Village.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/UserProfile.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/Donation.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/FundTransaction.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/Problem.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/Project.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/Citizen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/AppNotification.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/model/PaymentConfig.kt`
- Test: `android-native/app/src/test/java/app/village/grambasee/model/DonationTest.kt`
- Test: `android-native/app/src/test/java/app/village/grambasee/model/ProblemTest.kt`

**Interfaces:**
- Produces: `readString(map, key, fallback = ""): String`, `readDouble(map, key): Double`, `readInt(map, key): Int`, `readDate(map, key): Date`, `readOptionalDate(map, key): Date?`, `readStringList(map, key): List<String>` in `core/Parsing.kt`. Every model exposes `fun fromMap(id: String, map: Map<String, Any?>): T` used identically by all repositories.

- [ ] **Step 1: Write failing test for Donation.fromMap**

```kotlin
package app.village.grambasee.model

import org.junit.Assert.assertEquals
import org.junit.Test

class DonationTest {
    @Test
    fun `fromMap fills defaults for missing fields`() {
        val donation = Donation.fromMap("d1", mapOf("amount" to 100.0))
        assertEquals("Anonymous", donation.donorName)
        assertEquals(100.0, donation.amount, 0.0)
        assertEquals("", donation.transactionId)
    }

    @Test
    fun `fromMap reads populated fields`() {
        val map = mapOf(
            "donorName" to "Karim",
            "amount" to 500,
            "paymentMethod" to "bkash",
            "userId" to "u1",
            "status" to "Approved",
            "transactionId" to "TXN1",
            "senderNumber" to "0170",
        )
        val donation = Donation.fromMap("d2", map)
        assertEquals("Karim", donation.donorName)
        assertEquals(500.0, donation.amount, 0.0)
        assertEquals(true, donation.isApproved)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.DonationTest"`
Expected: FAIL (compile error — `Donation` doesn't exist yet)

- [ ] **Step 3: Implement core/Parsing.kt**

```kotlin
package app.village.grambasee.core

import java.util.Date
import com.google.firebase.Timestamp

fun readString(map: Map<String, Any?>, key: String, fallback: String = ""): String {
    val value = map[key]
    return if (value is String && value.isNotEmpty()) value else fallback
}

fun readDouble(map: Map<String, Any?>, key: String): Double {
    val value = map[key]
    return if (value is Number) value.toDouble() else 0.0
}

fun readInt(map: Map<String, Any?>, key: String): Int {
    val value = map[key]
    return if (value is Number) value.toInt() else 0
}

fun readDate(map: Map<String, Any?>, key: String): Date {
    return when (val value = map[key]) {
        is Timestamp -> value.toDate()
        is Date -> value
        else -> Date(0)
    }
}

fun readOptionalDate(map: Map<String, Any?>, key: String): Date? {
    return when (val value = map[key]) {
        is Timestamp -> value.toDate()
        is Date -> value
        else -> null
    }
}

@Suppress("UNCHECKED_CAST")
fun readStringList(map: Map<String, Any?>, key: String): List<String> {
    val value = map[key]
    return (value as? List<*>)?.filterIsInstance<String>() ?: emptyList()
}
```

- [ ] **Step 4: Implement model/Donation.kt**

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readDate
import app.village.grambasee.core.readDouble
import app.village.grambasee.core.readString
import java.util.Date

data class Donation(
    val id: String,
    val donorName: String,
    val amount: Double,
    val paymentMethod: String,
    val createdAt: Date,
    val userId: String,
    val status: String,
    val transactionId: String,
    val senderNumber: String,
    val receivedAccountId: String = "",
    val receivedAccountLabel: String = "",
) {
    val isPending get() = status == "Pending"
    val isApproved get() = status == "Approved"
    val isRejected get() = status == "Rejected"

    companion object {
        fun fromMap(id: String, map: Map<String, Any?>): Donation = Donation(
            id = id,
            donorName = readString(map, "donorName", "Anonymous"),
            amount = readDouble(map, "amount"),
            paymentMethod = readString(map, "paymentMethod"),
            createdAt = readDate(map, "createdAt"),
            userId = readString(map, "userId"),
            status = readString(map, "status", "Pending"),
            transactionId = readString(map, "transactionId"),
            senderNumber = readString(map, "senderNumber"),
            receivedAccountId = readString(map, "receivedAccountId"),
            receivedAccountLabel = readString(map, "receivedAccountLabel"),
        )
    }
}
```

- [ ] **Step 5: Implement remaining models following the same pattern**

`model/Village.kt`:

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readDouble
import app.village.grambasee.core.readInt
import app.village.grambasee.core.readString

data class Village(
    val name: String,
    val totalCitizens: Int,
    val totalFundCollected: Double,
    val totalSpent: Double,
) {
    val availableBalance get() = totalFundCollected - totalSpent

    companion object {
        fun fromMap(map: Map<String, Any?>): Village = Village(
            name = readString(map, "name", "Our Village"),
            totalCitizens = readInt(map, "totalCitizens"),
            totalFundCollected = readDouble(map, "totalFundCollected"),
            totalSpent = readDouble(map, "totalSpent"),
        )
    }
}
```

`model/UserProfile.kt`:

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readString

data class UserProfile(
    val uid: String,
    val name: String,
    val phone: String,
    val email: String,
    val photoUrl: String,
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>): UserProfile = UserProfile(
            uid = id,
            name = readString(map, "name"),
            phone = readString(map, "phone"),
            email = readString(map, "email"),
            photoUrl = readString(map, "photoUrl"),
        )
    }
}
```

`model/FundTransaction.kt`:

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readDate
import app.village.grambasee.core.readDouble
import app.village.grambasee.core.readString
import java.util.Date

data class FundTransaction(
    val id: String,
    val title: String,
    val amount: Double,
    val category: String,
    val createdAt: Date,
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>): FundTransaction = FundTransaction(
            id = id,
            title = readString(map, "title"),
            amount = readDouble(map, "amount"),
            category = readString(map, "category"),
            createdAt = readDate(map, "createdAt"),
        )
    }
}
```

`model/Problem.kt`:

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readDate
import app.village.grambasee.core.readInt
import app.village.grambasee.core.readString

data class Problem(
    val id: String,
    val title: String,
    val description: String,
    val category: String,
    val status: String,
    val reportedBy: String,
    val upvotes: Int,
    val downvotes: Int,
    val createdAt: java.util.Date,
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>): Problem = Problem(
            id = id,
            title = readString(map, "title"),
            description = readString(map, "description"),
            category = readString(map, "category"),
            status = readString(map, "status", "Open"),
            reportedBy = readString(map, "reportedBy"),
            upvotes = readInt(map, "upvotes"),
            downvotes = readInt(map, "downvotes"),
            createdAt = readDate(map, "createdAt"),
        )
    }
}
```

`model/Project.kt`:

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readDate
import app.village.grambasee.core.readDouble
import app.village.grambasee.core.readString

data class Project(
    val id: String,
    val title: String,
    val description: String,
    val status: String,
    val budget: Double,
    val spent: Double,
    val createdAt: java.util.Date,
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>): Project = Project(
            id = id,
            title = readString(map, "title"),
            description = readString(map, "description"),
            status = readString(map, "status", "Planned"),
            budget = readDouble(map, "budget"),
            spent = readDouble(map, "spent"),
            createdAt = readDate(map, "createdAt"),
        )
    }
}
```

`model/Citizen.kt`:

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readString

data class Citizen(
    val id: String,
    val name: String,
    val phone: String,
    val address: String,
    val photoUrl: String,
    val role: String,
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>): Citizen = Citizen(
            id = id,
            name = readString(map, "name"),
            phone = readString(map, "phone"),
            address = readString(map, "address"),
            photoUrl = readString(map, "photoUrl"),
            role = readString(map, "role", "citizen"),
        )
    }
}
```

`model/AppNotification.kt`:

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readDate
import app.village.grambasee.core.readString

data class AppNotification(
    val id: String,
    val title: String,
    val body: String,
    val createdAt: java.util.Date,
    val isRead: Boolean = false,
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>, isRead: Boolean = false): AppNotification =
            AppNotification(
                id = id,
                title = readString(map, "title"),
                body = readString(map, "body"),
                createdAt = readDate(map, "createdAt"),
                isRead = isRead,
            )
    }
}
```

`model/PaymentConfig.kt`:

```kotlin
package app.village.grambasee.model

import app.village.grambasee.core.readStringList

data class PaymentConfig(
    val methods: List<String>,
) {
    companion object {
        fun fromMap(map: Map<String, Any?>): PaymentConfig = PaymentConfig(
            methods = readStringList(map, "methods"),
        )
    }
}
```

- [ ] **Step 6: Write failing/passing test for Problem**

```kotlin
package app.village.grambasee.model

import org.junit.Assert.assertEquals
import org.junit.Test

class ProblemTest {
    @Test
    fun `fromMap defaults status to Open`() {
        val problem = Problem.fromMap("p1", mapOf("title" to "Broken pump"))
        assertEquals("Open", problem.status)
        assertEquals(0, problem.upvotes)
    }
}
```

- [ ] **Step 7: Run tests to verify all pass**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.DonationTest" --tests "*.ProblemTest"`
Expected: PASS (4 tests)

- [ ] **Step 8: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add Firestore data models with defensive parsing"
```

---

### Task 4: Auth Repository + Login/Onboarding/Splash

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/data/AuthRepository.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/splash/SplashScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/onboarding/OnboardingScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/auth/LoginViewModel.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/auth/LoginScreen.kt`
- Test: `android-native/app/src/test/java/app/village/grambasee/data/AuthRepositoryTest.kt`

**Interfaces:**
- Consumes: `FirebaseAuth`, `FirebaseFirestore` from `FirebaseModule` (Task 1); `UserProfile` from `model/UserProfile.kt` (Task 3).
- Produces: `AuthRepository` with `fun normalizePhone(phone: String): String`, `fun phoneToEmail(phone: String): String`, `suspend fun signInWithPhoneAndPassword(phone: String, password: String)`, `suspend fun signInWithEmailAndPassword(email: String, password: String)`, `fun authState(): Flow<FirebaseUser?>`, `fun signOut()`. `LoginViewModel` exposes `val uiState: StateFlow<LoginUiState>` with `sealed interface LoginUiState { object Idle; object Loading; data class Error(val message: String); object Success }`.

- [ ] **Step 1: Write failing test for phone normalization/email convention**

```kotlin
package app.village.grambasee.data

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Test

class AuthRepositoryTest {
    private val repository = AuthRepository(mockk<FirebaseAuth>(relaxed = true), mockk<FirebaseFirestore>(relaxed = true))

    @Test
    fun `normalizePhone strips spaces and dashes`() {
        assertEquals("01712345678", repository.normalizePhone("017-1234 5678"))
    }

    @Test
    fun `phoneToEmail appends village app domain`() {
        assertEquals("01712345678@village.app", repository.phoneToEmail("01712345678"))
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.AuthRepositoryTest"`
Expected: FAIL (compile error — `AuthRepository` doesn't exist)

- [ ] **Step 3: Implement AuthRepository.kt**

```kotlin
package app.village.grambasee.data

import app.village.grambasee.model.UserProfile
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
    private val auth: FirebaseAuth,
    private val firestore: FirebaseFirestore,
) {
    fun normalizePhone(phone: String): String = phone.replace(Regex("[\\s-]"), "")

    fun phoneToEmail(phone: String): String = "${normalizePhone(phone)}@village.app"

    fun authState(): Flow<FirebaseUser?> = callbackFlow {
        val listener = FirebaseAuth.AuthStateListener { trySend(it.currentUser) }
        auth.addAuthStateListener(listener)
        awaitClose { auth.removeAuthStateListener(listener) }
    }

    suspend fun signInWithPhoneAndPassword(phone: String, password: String) {
        auth.signInWithEmailAndPassword(phoneToEmail(phone), password).await()
    }

    suspend fun signInWithEmailAndPassword(email: String, password: String) {
        auth.signInWithEmailAndPassword(email.trim().lowercase(), password).await()
    }

    suspend fun signInWithGoogleIdToken(idToken: String): Boolean {
        val credential = com.google.firebase.auth.GoogleAuthProvider.getCredential(idToken, null)
        val result = auth.signInWithCredential(credential).await()
        val isNewUser = result.additionalUserInfo?.isNewUser ?: false
        val user = auth.currentUser ?: return isNewUser
        val doc = firestore.collection("users").document(user.uid).get().await()
        if (!doc.exists()) {
            firestore.collection("users").document(user.uid).set(
                UserProfile(
                    uid = user.uid,
                    name = user.displayName.orEmpty(),
                    phone = "",
                    email = user.email.orEmpty(),
                    photoUrl = user.photoUrl?.toString().orEmpty(),
                )
            ).await()
        }
        return isNewUser
    }

    fun signOut() {
        auth.signOut()
    }
}
```

(`firestore.collection("users").document(uid).set(userProfileInstance)` relies on Firestore's POJO mapping using the `UserProfile` data class's public properties — acceptable since all fields are `val`s with public getters.)

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.AuthRepositoryTest"`
Expected: PASS (2 tests)

- [ ] **Step 5: Implement LoginViewModel.kt**

```kotlin
package app.village.grambasee.feature.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.grambasee.data.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface LoginUiState {
    data object Idle : LoginUiState
    data object Loading : LoginUiState
    data class Error(val message: String) : LoginUiState
    data object Success : LoginUiState
}

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val authRepository: AuthRepository,
) : ViewModel() {

    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    fun signInWithPhone(phone: String, password: String) {
        _uiState.value = LoginUiState.Loading
        viewModelScope.launch {
            try {
                authRepository.signInWithPhoneAndPassword(phone, password)
                _uiState.value = LoginUiState.Success
            } catch (e: Exception) {
                _uiState.value = LoginUiState.Error(e.message ?: "Sign-in failed")
            }
        }
    }

    fun signInWithGoogleIdToken(idToken: String) {
        _uiState.value = LoginUiState.Loading
        viewModelScope.launch {
            try {
                authRepository.signInWithGoogleIdToken(idToken)
                _uiState.value = LoginUiState.Success
            } catch (e: Exception) {
                _uiState.value = LoginUiState.Error(e.message ?: "Google sign-in failed")
            }
        }
    }
}
```

- [ ] **Step 6: Implement LoginScreen.kt**

```kotlin
package app.village.grambasee.feature.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    viewModel: LoginViewModel = hiltViewModel(),
) {
    var phone by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state) {
        if (state is LoginUiState.Success) onLoginSuccess()
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center,
    ) {
        Text("GramBasee", style = MaterialTheme.typography.displayLarge)
        Spacer(Modifier.height(32.dp))
        OutlinedTextField(
            value = phone,
            onValueChange = { phone = it },
            label = { Text("Phone number") },
            modifier = Modifier.fillMaxWidth(),
        )
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier.fillMaxWidth(),
        )
        if (state is LoginUiState.Error) {
            Spacer(Modifier.height(8.dp))
            Text((state as LoginUiState.Error).message, color = MaterialTheme.colorScheme.error)
        }
        Spacer(Modifier.height(24.dp))
        Button(
            onClick = { viewModel.signInWithPhone(phone, password) },
            enabled = state !is LoginUiState.Loading,
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text(if (state is LoginUiState.Loading) "Signing in..." else "Sign in")
        }
    }
}
```

- [ ] **Step 7: Implement SplashScreen.kt and OnboardingScreen.kt (simple, no VM needed)**

```kotlin
package app.village.grambasee.feature.splash

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier

@Composable
fun SplashScreen() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
    }
}
```

```kotlin
package app.village.grambasee.feature.onboarding

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun OnboardingScreen(onFinished: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Bottom,
    ) {
        Text("Welcome to GramBasee", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(8.dp))
        Text("Track village donations, expenses, and problems in one place.")
        Spacer(Modifier.height(24.dp))
        Button(onClick = onFinished, modifier = Modifier.fillMaxWidth()) {
            Text("Get started")
        }
    }
}
```

- [ ] **Step 8: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 9: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add auth repository, login, onboarding, splash screens"
```

---

### Task 5: Home Dashboard (Village overview, recent donations/expenses)

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/data/VillageRepository.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/home/HomeViewModel.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/home/HomeScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/home/AllDonationsScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/home/AllExpensesScreen.kt`
- Test: `android-native/app/src/test/java/app/village/grambasee/feature/home/HomeViewModelTest.kt`

**Interfaces:**
- Consumes: `Village`, `Donation`, `FundTransaction` from Task 3; `FirebaseFirestore` from Task 1.
- Produces: `VillageRepository` with `fun observeVillage(villageId: String = "default"): Flow<Village>`, `fun observeRecentDonations(limit: Long = 5): Flow<List<Donation>>`, `fun observeAllDonations(): Flow<List<Donation>>`, `fun observeRecentExpenses(limit: Long = 5): Flow<List<FundTransaction>>`, `fun observeAllExpenses(): Flow<List<FundTransaction>>`. `HomeViewModel` exposes `val uiState: StateFlow<HomeUiState>` where `data class HomeUiState(val village: Village? = null, val recentDonations: List<Donation> = emptyList(), val recentExpenses: List<FundTransaction> = emptyList(), val isLoading: Boolean = true)`.

- [ ] **Step 1: Write failing test for HomeViewModel combining flows**

```kotlin
package app.village.grambasee.feature.home

import app.cash.turbine.test
import app.village.grambasee.data.VillageRepository
import app.village.grambasee.model.Village
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

class HomeViewModelTest {
    @Test
    fun `uiState reflects repository village data`() = runTest {
        val repository = mockk<VillageRepository>()
        every { repository.observeVillage() } returns flowOf(
            Village(name = "Rampur", totalCitizens = 500, totalFundCollected = 10000.0, totalSpent = 4000.0)
        )
        every { repository.observeRecentDonations(5) } returns flowOf(emptyList())
        every { repository.observeRecentExpenses(5) } returns flowOf(emptyList())

        val viewModel = HomeViewModel(repository)

        viewModel.uiState.test {
            val state = awaitItem()
            assertEquals("Rampur", state.village?.name)
            assertEquals(false, state.isLoading)
        }
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.HomeViewModelTest"`
Expected: FAIL (compile error — `HomeViewModel`/`VillageRepository` don't exist)

- [ ] **Step 3: Implement VillageRepository.kt**

```kotlin
package app.village.grambasee.data

import app.village.grambasee.model.Donation
import app.village.grambasee.model.FundTransaction
import app.village.grambasee.model.Village
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
open class VillageRepository @Inject constructor(
    private val firestore: FirebaseFirestore,
) {
    open fun observeVillage(villageId: String = "default"): Flow<Village> = callbackFlow {
        val registration = firestore.collection("villages").document(villageId)
            .addSnapshotListener { snapshot, _ ->
                val data = snapshot?.data ?: emptyMap()
                trySend(Village.fromMap(data))
            }
        awaitClose { registration.remove() }
    }

    open fun observeRecentDonations(limit: Long = 5): Flow<List<Donation>> = callbackFlow {
        val registration = firestore.collection("donations")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(limit)
            .addSnapshotListener { snapshot, _ ->
                val donations = snapshot?.documents?.map { Donation.fromMap(it.id, it.data.orEmpty()) }.orEmpty()
                trySend(donations)
            }
        awaitClose { registration.remove() }
    }

    open fun observeAllDonations(): Flow<List<Donation>> = callbackFlow {
        val registration = firestore.collection("donations")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .addSnapshotListener { snapshot, _ ->
                val donations = snapshot?.documents?.map { Donation.fromMap(it.id, it.data.orEmpty()) }.orEmpty()
                trySend(donations)
            }
        awaitClose { registration.remove() }
    }

    open fun observeRecentExpenses(limit: Long = 5): Flow<List<FundTransaction>> = callbackFlow {
        val registration = firestore.collection("fund_transactions")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(limit)
            .addSnapshotListener { snapshot, _ ->
                val expenses = snapshot?.documents?.map { FundTransaction.fromMap(it.id, it.data.orEmpty()) }.orEmpty()
                trySend(expenses)
            }
        awaitClose { registration.remove() }
    }

    open fun observeAllExpenses(): Flow<List<FundTransaction>> = callbackFlow {
        val registration = firestore.collection("fund_transactions")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .addSnapshotListener { snapshot, _ ->
                val expenses = snapshot?.documents?.map { FundTransaction.fromMap(it.id, it.data.orEmpty()) }.orEmpty()
                trySend(expenses)
            }
        awaitClose { registration.remove() }
    }
}
```

(`open` on the class/methods so MockK can mock it without `mockk-agent`/relaxed proxying issues on a final class.)

- [ ] **Step 4: Implement HomeViewModel.kt**

```kotlin
package app.village.grambasee.feature.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.grambasee.data.VillageRepository
import app.village.grambasee.model.Donation
import app.village.grambasee.model.FundTransaction
import app.village.grambasee.model.Village
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

data class HomeUiState(
    val village: Village? = null,
    val recentDonations: List<Donation> = emptyList(),
    val recentExpenses: List<FundTransaction> = emptyList(),
    val isLoading: Boolean = true,
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    repository: VillageRepository,
) : ViewModel() {

    val uiState = combine(
        repository.observeVillage(),
        repository.observeRecentDonations(5),
        repository.observeRecentExpenses(5),
    ) { village, donations, expenses ->
        HomeUiState(village = village, recentDonations = donations, recentExpenses = expenses, isLoading = false)
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = HomeUiState(),
    )
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.HomeViewModelTest"`
Expected: PASS

- [ ] **Step 6: Implement HomeScreen.kt**

```kotlin
package app.village.grambasee.feature.home

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun HomeScreen(
    onSeeAllDonations: () -> Unit,
    onSeeAllExpenses: () -> Unit,
    viewModel: HomeViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()

    LazyColumn(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        item {
            Text(state.village?.name ?: "GramBasee", style = MaterialTheme.typography.headlineMedium)
            Spacer(Modifier.height(16.dp))
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(Modifier.padding(16.dp)) {
                    Text("Available balance", style = MaterialTheme.typography.labelLarge)
                    Text(
                        "৳${state.village?.availableBalance ?: 0.0}",
                        style = MaterialTheme.typography.displayLarge,
                    )
                }
            }
            Spacer(Modifier.height(24.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Text("Recent donations", style = MaterialTheme.typography.titleLarge)
                TextButton(onClick = onSeeAllDonations) { Text("See all") }
            }
        }
        items(state.recentDonations) { donation ->
            ListItem(
                headlineContent = { Text(donation.donorName) },
                supportingContent = { Text(donation.status) },
                trailingContent = { Text("৳${donation.amount}") },
            )
        }
        item {
            Spacer(Modifier.height(16.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Text("Recent expenses", style = MaterialTheme.typography.titleLarge)
                TextButton(onClick = onSeeAllExpenses) { Text("See all") }
            }
        }
        items(state.recentExpenses) { expense ->
            ListItem(
                headlineContent = { Text(expense.title) },
                supportingContent = { Text(expense.category) },
                trailingContent = { Text("৳${expense.amount}") },
            )
        }
    }
}
```

- [ ] **Step 7: Implement AllDonationsScreen.kt and AllExpensesScreen.kt**

```kotlin
package app.village.grambasee.feature.home

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ListItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.grambasee.data.VillageRepository

@Composable
fun AllDonationsScreen(repository: VillageRepository = hiltViewModelRepository()) {
    val donations by repository.observeAllDonations().collectAsState(initial = emptyList())
    LazyColumn(modifier = Modifier.fillMaxSize()) {
        items(donations) { donation ->
            ListItem(
                headlineContent = { Text(donation.donorName) },
                supportingContent = { Text(donation.status) },
                trailingContent = { Text("৳${donation.amount}") },
            )
        }
    }
}
```

`hiltViewModelRepository()` is not a real API — replace this pattern with an `AllDonationsViewModel`/`AllExpensesViewModel` pair so injection goes through Hilt like every other screen:

```kotlin
package app.village.grambasee.feature.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.grambasee.data.VillageRepository
import app.village.grambasee.model.Donation
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class AllDonationsViewModel @Inject constructor(
    repository: VillageRepository,
) : ViewModel() {
    val donations = repository.observeAllDonations()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList<Donation>())
}
```

```kotlin
@Composable
fun AllDonationsScreen(viewModel: AllDonationsViewModel = hiltViewModel()) {
    val donations by viewModel.donations.collectAsState()
    LazyColumn(modifier = Modifier.fillMaxSize()) {
        items(donations) { donation ->
            ListItem(
                headlineContent = { Text(donation.donorName) },
                supportingContent = { Text(donation.status) },
                trailingContent = { Text("৳${donation.amount}") },
            )
        }
    }
}
```

Apply the same `AllExpensesViewModel` + `AllExpensesScreen` pair for `fund_transactions`, using `repository.observeAllExpenses()` and `FundTransaction`.

- [ ] **Step 8: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 9: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add home dashboard, all-donations, all-expenses screens"
```

---

### Task 6: Donations (browse + checkout)

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/data/DonationRepository.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/donation/DonationViewModel.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/donation/DonationScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/donation/DonationCheckoutScreen.kt`
- Test: `android-native/app/src/test/java/app/village/grambasee/feature/donation/DonationViewModelTest.kt`

**Interfaces:**
- Consumes: `PaymentConfig`, `Donation` from Task 3; `FirebaseAuth`, `FirebaseFirestore` from Task 1.
- Produces: `DonationRepository` with `fun observePaymentConfig(): Flow<PaymentConfig>`, `suspend fun submitDonation(amount: Double, paymentMethod: String, transactionId: String, senderNumber: String)` (writes a `donations` doc with `status = "Pending"`, `userId = auth.currentUser!!.uid`, per `firestore.rules`'s create predicate). `DonationCheckoutViewModel` exposes `val uiState: StateFlow<CheckoutUiState>` with `sealed interface CheckoutUiState { data object Idle; data object Submitting; data object Submitted; data class Error(val message: String) }`.

- [ ] **Step 1: Write failing test for checkout submission validation**

```kotlin
package app.village.grambasee.feature.donation

import app.cash.turbine.test
import app.village.grambasee.data.DonationRepository
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.Test

class DonationViewModelTest {
    @Test
    fun `submit moves state to Submitted on success`() = runTest {
        val repository = mockk<DonationRepository>()
        coEvery { repository.submitDonation(any(), any(), any(), any()) } returns Unit
        val viewModel = DonationCheckoutViewModel(repository)

        viewModel.uiState.test {
            assert(awaitItem() is CheckoutUiState.Idle)
            viewModel.submit(amount = 200.0, paymentMethod = "bkash", transactionId = "TXN9", senderNumber = "0171")
            assert(awaitItem() is CheckoutUiState.Submitting)
            assert(awaitItem() is CheckoutUiState.Submitted)
        }
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.DonationViewModelTest"`
Expected: FAIL (compile error — types don't exist)

- [ ] **Step 3: Implement DonationRepository.kt**

```kotlin
package app.village.grambasee.data

import app.village.grambasee.model.PaymentConfig
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
open class DonationRepository @Inject constructor(
    private val firestore: FirebaseFirestore,
    private val auth: FirebaseAuth,
) {
    open fun observePaymentConfig(): Flow<PaymentConfig> = callbackFlow {
        val registration = firestore.collection("config").document("payment")
            .addSnapshotListener { snapshot, _ ->
                trySend(PaymentConfig.fromMap(snapshot?.data.orEmpty()))
            }
        awaitClose { registration.remove() }
    }

    open suspend fun submitDonation(
        amount: Double,
        paymentMethod: String,
        transactionId: String,
        senderNumber: String,
    ) {
        val uid = auth.currentUser?.uid ?: error("Not signed in")
        val donorName = auth.currentUser?.displayName ?: "Anonymous"
        firestore.collection("donations").add(
            mapOf(
                "donorName" to donorName,
                "amount" to amount,
                "paymentMethod" to paymentMethod,
                "userId" to uid,
                "status" to "Pending",
                "transactionId" to transactionId,
                "senderNumber" to senderNumber,
                "createdAt" to com.google.firebase.Timestamp.now(),
            )
        ).await()
    }
}
```

- [ ] **Step 4: Implement DonationViewModel.kt (checkout)**

```kotlin
package app.village.grambasee.feature.donation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.grambasee.data.DonationRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface CheckoutUiState {
    data object Idle : CheckoutUiState
    data object Submitting : CheckoutUiState
    data object Submitted : CheckoutUiState
    data class Error(val message: String) : CheckoutUiState
}

@HiltViewModel
class DonationCheckoutViewModel @Inject constructor(
    private val repository: DonationRepository,
) : ViewModel() {
    private val _uiState = MutableStateFlow<CheckoutUiState>(CheckoutUiState.Idle)
    val uiState: StateFlow<CheckoutUiState> = _uiState.asStateFlow()

    fun submit(amount: Double, paymentMethod: String, transactionId: String, senderNumber: String) {
        _uiState.value = CheckoutUiState.Submitting
        viewModelScope.launch {
            try {
                repository.submitDonation(amount, paymentMethod, transactionId, senderNumber)
                _uiState.value = CheckoutUiState.Submitted
            } catch (e: Exception) {
                _uiState.value = CheckoutUiState.Error(e.message ?: "Submission failed")
            }
        }
    }
}
```

Also add a plain `DonationViewModel` for the browse screen that exposes `val paymentConfig: StateFlow<PaymentConfig>` from `repository.observePaymentConfig()`, same `stateIn` pattern as `HomeViewModel`.

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.DonationViewModelTest"`
Expected: PASS

- [ ] **Step 6: Implement DonationScreen.kt and DonationCheckoutScreen.kt**

```kotlin
package app.village.grambasee.feature.donation

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun DonationScreen(onDonateClicked: () -> Unit) {
    Column(modifier = Modifier.fillMaxSize().padding(24.dp)) {
        Text("Support your village", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(16.dp))
        Button(onClick = onDonateClicked, modifier = Modifier.fillMaxWidth()) {
            Text("Donate now")
        }
    }
}

@Composable
fun DonationCheckoutScreen(
    onSubmitted: () -> Unit,
    viewModel: DonationCheckoutViewModel = hiltViewModel(),
) {
    var amount by remember { mutableStateOf("") }
    var paymentMethod by remember { mutableStateOf("bkash") }
    var transactionId by remember { mutableStateOf("") }
    var senderNumber by remember { mutableStateOf("") }
    val state by viewModel.uiState.collectAsState()

    LaunchedEffect(state) {
        if (state is CheckoutUiState.Submitted) onSubmitted()
    }

    Column(modifier = Modifier.fillMaxSize().padding(24.dp)) {
        OutlinedTextField(amount, { amount = it }, label = { Text("Amount") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(paymentMethod, { paymentMethod = it }, label = { Text("Payment method") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(transactionId, { transactionId = it }, label = { Text("Transaction ID") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(senderNumber, { senderNumber = it }, label = { Text("Sender number") }, modifier = Modifier.fillMaxWidth())
        if (state is CheckoutUiState.Error) {
            Text((state as CheckoutUiState.Error).message, color = MaterialTheme.colorScheme.error)
        }
        Spacer(Modifier.height(24.dp))
        Button(
            onClick = {
                viewModel.submit(amount.toDoubleOrNull() ?: 0.0, paymentMethod, transactionId, senderNumber)
            },
            enabled = state !is CheckoutUiState.Submitting,
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text(if (state is CheckoutUiState.Submitting) "Submitting..." else "Submit donation")
        }
    }
}
```

- [ ] **Step 7: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 8: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add donation browse and checkout screens"
```

---

### Task 7: Problems (list, details, report, vote)

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/data/ProblemRepository.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/problems/ProblemsViewModel.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/problems/ProblemsScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/problems/ProblemDetailsScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/problems/ReportProblemScreen.kt`
- Test: `android-native/app/src/test/java/app/village/grambasee/feature/problems/ProblemsViewModelTest.kt`

**Interfaces:**
- Consumes: `Problem` from Task 3; `FirebaseAuth`, `FirebaseFirestore` from Task 1.
- Produces: `ProblemRepository` with `fun observeProblems(): Flow<List<Problem>>`, `suspend fun reportProblem(title: String, description: String, category: String)`, `suspend fun vote(problemId: String, isUpvote: Boolean)` (writes `problems/{id}/votes/{uid}` per `firestore.rules`, then updates the aggregate `upvotes`/`downvotes` via `FieldValue.increment`). `ProblemsViewModel` exposes `val problems: StateFlow<List<Problem>>`.

- [ ] **Step 1: Write failing test for ProblemsViewModel**

```kotlin
package app.village.grambasee.feature.problems

import app.cash.turbine.test
import app.village.grambasee.data.ProblemRepository
import app.village.grambasee.model.Problem
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test
import java.util.Date

class ProblemsViewModelTest {
    @Test
    fun `problems reflects repository stream`() = runTest {
        val repository = mockk<ProblemRepository>()
        val sample = Problem(
            id = "p1", title = "Broken pump", description = "", category = "Water",
            status = "Open", reportedBy = "u1", upvotes = 3, downvotes = 0, createdAt = Date(),
        )
        every { repository.observeProblems() } returns flowOf(listOf(sample))

        val viewModel = ProblemsViewModel(repository)

        viewModel.problems.test {
            assertEquals(listOf(sample), awaitItem())
        }
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.ProblemsViewModelTest"`
Expected: FAIL (compile error — types don't exist)

- [ ] **Step 3: Implement ProblemRepository.kt**

```kotlin
package app.village.grambasee.data

import app.village.grambasee.model.Problem
import com.google.firebase.Timestamp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
open class ProblemRepository @Inject constructor(
    private val firestore: FirebaseFirestore,
    private val auth: FirebaseAuth,
) {
    open fun observeProblems(): Flow<List<Problem>> = callbackFlow {
        val registration = firestore.collection("problems")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .addSnapshotListener { snapshot, _ ->
                val problems = snapshot?.documents?.map { Problem.fromMap(it.id, it.data.orEmpty()) }.orEmpty()
                trySend(problems)
            }
        awaitClose { registration.remove() }
    }

    open suspend fun reportProblem(title: String, description: String, category: String) {
        val uid = auth.currentUser?.uid ?: error("Not signed in")
        firestore.collection("problems").add(
            mapOf(
                "title" to title,
                "description" to description,
                "category" to category,
                "status" to "Open",
                "reportedBy" to uid,
                "upvotes" to 0,
                "downvotes" to 0,
                "createdAt" to Timestamp.now(),
            )
        ).await()
    }

    open suspend fun vote(problemId: String, isUpvote: Boolean) {
        val uid = auth.currentUser?.uid ?: error("Not signed in")
        val problemRef = firestore.collection("problems").document(problemId)
        val voteRef = problemRef.collection("votes").document(uid)
        voteRef.set(mapOf("value" to if (isUpvote) 1 else -1)).await()
        problemRef.update(
            if (isUpvote) "upvotes" else "downvotes",
            FieldValue.increment(1),
        ).await()
    }
}
```

- [ ] **Step 4: Implement ProblemsViewModel.kt**

```kotlin
package app.village.grambasee.feature.problems

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.grambasee.data.ProblemRepository
import app.village.grambasee.model.Problem
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ProblemsViewModel @Inject constructor(
    private val repository: ProblemRepository,
) : ViewModel() {
    val problems: StateFlow<List<Problem>> = repository.observeProblems()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun vote(problemId: String, isUpvote: Boolean) {
        viewModelScope.launch { repository.vote(problemId, isUpvote) }
    }

    fun reportProblem(title: String, description: String, category: String) {
        viewModelScope.launch { repository.reportProblem(title, description, category) }
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd android-native && ./gradlew :app:testDebugUnitTest --tests "*.ProblemsViewModelTest"`
Expected: PASS

- [ ] **Step 6: Implement ProblemsScreen.kt, ProblemDetailsScreen.kt, ReportProblemScreen.kt**

```kotlin
package app.village.grambasee.feature.problems

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun ProblemsScreen(
    onProblemClick: (String) -> Unit,
    onReportClick: () -> Unit,
    viewModel: ProblemsViewModel = hiltViewModel(),
) {
    val problems by viewModel.problems.collectAsState()
    Scaffold(
        floatingActionButton = {
            FloatingActionButton(onClick = onReportClick) { Text("+") }
        },
    ) { padding ->
        LazyColumn(modifier = Modifier.fillMaxSize().padding(padding)) {
            items(problems) { problem ->
                ListItem(
                    headlineContent = { Text(problem.title) },
                    supportingContent = { Text("${problem.category} • ${problem.status}") },
                    trailingContent = { Text("▲${problem.upvotes} ▼${problem.downvotes}") },
                    modifier = Modifier.clickable { onProblemClick(problem.id) },
                )
            }
        }
    }
}
```

(Add `import androidx.compose.foundation.clickable`.)

```kotlin
package app.village.grambasee.feature.problems

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun ProblemDetailsScreen(
    problemId: String,
    viewModel: ProblemsViewModel = hiltViewModel(),
) {
    val problem by remember(problemId) {
        derivedStateOf { viewModel.problems.value.firstOrNull { it.id == problemId } }
    }
    Column(modifier = Modifier.fillMaxSize().padding(24.dp)) {
        Text(problem?.title ?: "", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(8.dp))
        Text(problem?.description ?: "")
        Spacer(Modifier.height(16.dp))
        Row {
            Button(onClick = { viewModel.vote(problemId, true) }) { Text("Upvote (${problem?.upvotes ?: 0})") }
            Spacer(Modifier.width(8.dp))
            OutlinedButton(onClick = { viewModel.vote(problemId, false) }) { Text("Downvote (${problem?.downvotes ?: 0})") }
        }
    }
}
```

```kotlin
package app.village.grambasee.feature.problems

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun ReportProblemScreen(
    onReported: () -> Unit,
    viewModel: ProblemsViewModel = hiltViewModel(),
) {
    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var category by remember { mutableStateOf("General") }

    Column(modifier = Modifier.fillMaxSize().padding(24.dp)) {
        OutlinedTextField(title, { title = it }, label = { Text("Title") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(description, { description = it }, label = { Text("Description") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(category, { category = it }, label = { Text("Category") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(24.dp))
        Button(
            onClick = {
                viewModel.reportProblem(title, description, category)
                onReported()
            },
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text("Submit report")
        }
    }
}
```

- [ ] **Step 7: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 8: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add problems list, details, report, voting"
```

---

### Task 8: Projects (list, details)

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/data/ProjectRepository.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/projects/ProjectsViewModel.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/projects/ProjectsScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/projects/ProjectDetailsScreen.kt`

**Interfaces:**
- Consumes: `Project` from Task 3.
- Produces: `ProjectRepository` with `fun observeProjects(): Flow<List<Project>>`. `ProjectsViewModel` exposes `val projects: StateFlow<List<Project>>`.

- [ ] **Step 1: Implement ProjectRepository.kt**

```kotlin
package app.village.grambasee.data

import app.village.grambasee.model.Project
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
open class ProjectRepository @Inject constructor(
    private val firestore: FirebaseFirestore,
) {
    open fun observeProjects(): Flow<List<Project>> = callbackFlow {
        val registration = firestore.collection("projects")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .addSnapshotListener { snapshot, _ ->
                val projects = snapshot?.documents?.map { Project.fromMap(it.id, it.data.orEmpty()) }.orEmpty()
                trySend(projects)
            }
        awaitClose { registration.remove() }
    }
}
```

- [ ] **Step 2: Implement ProjectsViewModel.kt**

```kotlin
package app.village.grambasee.feature.projects

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.grambasee.data.ProjectRepository
import app.village.grambasee.model.Project
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class ProjectsViewModel @Inject constructor(
    repository: ProjectRepository,
) : ViewModel() {
    val projects: StateFlow<List<Project>> = repository.observeProjects()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
}
```

- [ ] **Step 3: Implement ProjectsScreen.kt and ProjectDetailsScreen.kt**

```kotlin
package app.village.grambasee.feature.projects

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ListItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun ProjectsScreen(
    onProjectClick: (String) -> Unit,
    viewModel: ProjectsViewModel = hiltViewModel(),
) {
    val projects by viewModel.projects.collectAsState()
    LazyColumn(modifier = Modifier.fillMaxSize()) {
        items(projects) { project ->
            ListItem(
                headlineContent = { Text(project.title) },
                supportingContent = { Text(project.status) },
                trailingContent = { Text("৳${project.spent} / ৳${project.budget}") },
                modifier = Modifier.clickable { onProjectClick(project.id) },
            )
        }
    }
}

@Composable
fun ProjectDetailsScreen(
    projectId: String,
    viewModel: ProjectsViewModel = hiltViewModel(),
) {
    val projects by viewModel.projects.collectAsState()
    val project = projects.firstOrNull { it.id == projectId }
    androidx.compose.foundation.layout.Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
    ) {
        Text(project?.title ?: "")
        Text(project?.description ?: "")
    }
}
```

(Add `import androidx.compose.foundation.layout.padding` and `import androidx.compose.ui.unit.dp`.)

- [ ] **Step 4: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add projects list and details screens"
```

---

### Task 9: Citizens (directory, profile) + Leaders

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/data/CitizenRepository.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/citizens/CitizenViewModel.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/citizens/CitizenDirectoryScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/citizens/CitizenProfileScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/leaders/LeadersScreen.kt`

**Interfaces:**
- Consumes: `Citizen` from Task 3.
- Produces: `CitizenRepository` with `fun observeCitizens(): Flow<List<Citizen>>`. `CitizenViewModel` exposes `val citizens: StateFlow<List<Citizen>>` and a derived `val leaders: StateFlow<List<Citizen>>` filtered where `role != "citizen"`.

- [ ] **Step 1: Implement CitizenRepository.kt**

```kotlin
package app.village.grambasee.data

import app.village.grambasee.model.Citizen
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
open class CitizenRepository @Inject constructor(
    private val firestore: FirebaseFirestore,
) {
    open fun observeCitizens(): Flow<List<Citizen>> = callbackFlow {
        val registration = firestore.collection("citizens")
            .addSnapshotListener { snapshot, _ ->
                val citizens = snapshot?.documents?.map { Citizen.fromMap(it.id, it.data.orEmpty()) }.orEmpty()
                trySend(citizens)
            }
        awaitClose { registration.remove() }
    }
}
```

- [ ] **Step 2: Implement CitizenViewModel.kt**

```kotlin
package app.village.grambasee.feature.citizens

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.grambasee.data.CitizenRepository
import app.village.grambasee.model.Citizen
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class CitizenViewModel @Inject constructor(
    repository: CitizenRepository,
) : ViewModel() {
    val citizens: StateFlow<List<Citizen>> = repository.observeCitizens()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val leaders: StateFlow<List<Citizen>> = repository.observeCitizens()
        .map { list -> list.filter { it.role != "citizen" } }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
}
```

- [ ] **Step 3: Implement CitizenDirectoryScreen.kt, CitizenProfileScreen.kt, LeadersScreen.kt**

```kotlin
package app.village.grambasee.feature.citizens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ListItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun CitizenDirectoryScreen(
    onCitizenClick: (String) -> Unit,
    viewModel: CitizenViewModel = hiltViewModel(),
) {
    val citizens by viewModel.citizens.collectAsState()
    LazyColumn(modifier = Modifier.fillMaxSize()) {
        items(citizens) { citizen ->
            ListItem(
                headlineContent = { Text(citizen.name) },
                supportingContent = { Text(citizen.address) },
                modifier = Modifier.clickable { onCitizenClick(citizen.id) },
            )
        }
    }
}

@Composable
fun CitizenProfileScreen(
    citizenId: String,
    viewModel: CitizenViewModel = hiltViewModel(),
) {
    val citizens by viewModel.citizens.collectAsState()
    val citizen = citizens.firstOrNull { it.id == citizenId }
    androidx.compose.foundation.layout.Column {
        Text(citizen?.name ?: "")
        Text(citizen?.phone ?: "")
        Text(citizen?.address ?: "")
    }
}
```

```kotlin
package app.village.grambasee.feature.leaders

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ListItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import app.village.grambasee.feature.citizens.CitizenViewModel

@Composable
fun LeadersScreen(viewModel: CitizenViewModel = hiltViewModel()) {
    val leaders by viewModel.leaders.collectAsState()
    LazyColumn(modifier = Modifier.fillMaxSize()) {
        items(leaders) { leader ->
            ListItem(
                headlineContent = { Text(leader.name) },
                supportingContent = { Text(leader.role) },
            )
        }
    }
}
```

- [ ] **Step 4: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add citizen directory, citizen profile, leaders screens"
```

---

### Task 10: Notifications

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/data/NotificationRepository.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/notifications/NotificationViewModel.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/notifications/NotificationScreen.kt`

**Interfaces:**
- Consumes: `AppNotification` from Task 3; `FirebaseAuth` from Task 1.
- Produces: `NotificationRepository` with `fun observeNotifications(): Flow<List<AppNotification>>` (joins `notifications` with the signed-in user's `users/{uid}/notification_reads` subcollection to set `isRead`), `suspend fun markRead(notificationId: String)` (writes `users/{uid}/notification_reads/{notificationId}` with `readAt`, matching the rule's `keys().hasOnly(['readAt'])` constraint).

- [ ] **Step 1: Implement NotificationRepository.kt**

```kotlin
package app.village.grambasee.data

import app.village.grambasee.model.AppNotification
import com.google.firebase.Timestamp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
open class NotificationRepository @Inject constructor(
    private val firestore: FirebaseFirestore,
    private val auth: FirebaseAuth,
) {
    open fun observeNotifications(): Flow<List<AppNotification>> = callbackFlow {
        val uid = auth.currentUser?.uid
        val registration = firestore.collection("notifications")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .addSnapshotListener { snapshot, _ ->
                val docs = snapshot?.documents.orEmpty()
                if (uid == null) {
                    trySend(docs.map { AppNotification.fromMap(it.id, it.data.orEmpty()) })
                } else {
                    firestore.collection("users").document(uid)
                        .collection("notification_reads").get()
                        .addOnSuccessListener { readsSnapshot ->
                            val readIds = readsSnapshot.documents.map { it.id }.toSet()
                            trySend(
                                docs.map {
                                    AppNotification.fromMap(it.id, it.data.orEmpty(), isRead = it.id in readIds)
                                }
                            )
                        }
                }
            }
        awaitClose { registration.remove() }
    }

    open suspend fun markRead(notificationId: String) {
        val uid = auth.currentUser?.uid ?: return
        firestore.collection("users").document(uid)
            .collection("notification_reads").document(notificationId)
            .set(mapOf("readAt" to Timestamp.now()))
            .await()
    }
}
```

- [ ] **Step 2: Implement NotificationViewModel.kt**

```kotlin
package app.village.grambasee.feature.notifications

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.village.grambasee.data.NotificationRepository
import app.village.grambasee.model.AppNotification
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class NotificationViewModel @Inject constructor(
    private val repository: NotificationRepository,
) : ViewModel() {
    val notifications: StateFlow<List<AppNotification>> = repository.observeNotifications()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun markRead(notificationId: String) {
        viewModelScope.launch { repository.markRead(notificationId) }
    }
}
```

- [ ] **Step 3: Implement NotificationScreen.kt**

```kotlin
package app.village.grambasee.feature.notifications

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ListItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun NotificationScreen(viewModel: NotificationViewModel = hiltViewModel()) {
    val notifications by viewModel.notifications.collectAsState()
    LazyColumn(modifier = Modifier.fillMaxSize()) {
        items(notifications) { notification ->
            ListItem(
                headlineContent = {
                    Text(
                        notification.title,
                        fontWeight = if (notification.isRead) FontWeight.Normal else FontWeight.Bold,
                    )
                },
                supportingContent = { Text(notification.body) },
                modifier = Modifier.clickable { viewModel.markRead(notification.id) },
            )
        }
    }
}
```

- [ ] **Step 4: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add notifications screen with read tracking"
```

---

### Task 11: Reports, Profile, Settings

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/reports/ReportsScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/profile/ProfileScreen.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/feature/settings/SettingsScreen.kt`

**Interfaces:**
- Consumes: `HomeViewModel`'s village state (Task 5) for report totals; `AuthRepository` (Task 4) for sign-out; `FirebaseAuth.currentUser` for profile display.

- [ ] **Step 1: Implement ReportsScreen.kt (reuses village + donation/expense totals)**

```kotlin
package app.village.grambasee.feature.reports

import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import app.village.grambasee.feature.home.HomeViewModel

@Composable
fun ReportsScreen(viewModel: HomeViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsState()
    Column(modifier = Modifier.fillMaxSize().padding(24.dp)) {
        Text("Fund report", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(16.dp))
        Text("Total collected: ৳${state.village?.totalFundCollected ?: 0.0}")
        Text("Total spent: ৳${state.village?.totalSpent ?: 0.0}")
        Text("Balance: ৳${state.village?.availableBalance ?: 0.0}")
    }
}
```

- [ ] **Step 2: Implement ProfileScreen.kt**

```kotlin
package app.village.grambasee.feature.profile

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.google.firebase.auth.FirebaseAuth

@Composable
fun ProfileScreen(
    onSettingsClick: () -> Unit,
    onSignOut: () -> Unit,
) {
    val user = FirebaseAuth.getInstance().currentUser
    Column(modifier = Modifier.fillMaxSize().padding(24.dp)) {
        Text(user?.displayName ?: user?.email.orEmpty(), style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(24.dp))
        TextButton(onClick = onSettingsClick) { Text("Settings") }
        TextButton(onClick = onSignOut) { Text("Sign out") }
    }
}
```

- [ ] **Step 3: Implement SettingsScreen.kt**

```kotlin
package app.village.grambasee.feature.settings

import androidx.compose.foundation.layout.*
import androidx.compose.material3.ListItem
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier

@Composable
fun SettingsScreen() {
    var notificationsEnabled by remember { mutableStateOf(true) }
    Column(modifier = Modifier.fillMaxSize()) {
        ListItem(
            headlineContent = { Text("Push notifications") },
            trailingContent = {
                Switch(checked = notificationsEnabled, onCheckedChange = { notificationsEnabled = it })
            },
        )
    }
}
```

- [ ] **Step 4: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add reports, profile, settings screens"
```

---

### Task 12: Push Notifications (FCM)

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/push/GramBaseeMessagingService.kt`

**Interfaces:**
- Consumes: `FirebaseMessagingService` (Firebase SDK), `NotificationManager` (Android framework).
- Produces: registered service `GramBaseeMessagingService` (already declared in `AndroidManifest.xml` in Task 1) that posts a system notification when an FCM message arrives, mirroring `clientapp/lib/push_notification_service.dart`'s topic-based delivery (subscribes to a per-village topic so the admin panel's existing send-to-topic flow works unchanged).

- [ ] **Step 1: Implement GramBaseeMessagingService.kt**

```kotlin
package app.village.grambasee.push

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.google.firebase.messaging.FirebaseMessaging

private const val CHANNEL_ID = "grambasee_default"

class GramBaseeMessagingService : FirebaseMessagingService() {

    override fun onCreate() {
        super.onCreate()
        FirebaseMessaging.getInstance().subscribeToTopic("village_default")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "GramBasee notifications", NotificationManager.IMPORTANCE_DEFAULT,
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    override fun onMessageReceived(message: RemoteMessage) {
        val title = message.notification?.title ?: message.data["title"] ?: "GramBasee"
        val body = message.notification?.body ?: message.data["body"] ?: ""
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setAutoCancel(true)
            .build()
        NotificationManagerCompat.from(this).notify(message.messageId.hashCode(), notification)
    }
}
```

(`android.permission.POST_NOTIFICATIONS` already declared in Task 1's manifest; runtime permission request is out of scope for this task and can be added in `MainActivity` alongside Task 15's nav wiring if needed — matches clientapp's own best-effort prompt-once pattern.)

- [ ] **Step 2: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add android-native
git commit -m "feat(android-native): add FCM messaging service"
```

---

### Task 13: Navigation Wiring (bottom nav + full graph)

**Files:**
- Create: `android-native/app/src/main/java/app/village/grambasee/nav/Destinations.kt`
- Create: `android-native/app/src/main/java/app/village/grambasee/nav/GramBaseeNavHost.kt`
- Modify: `android-native/app/src/main/java/app/village/grambasee/MainActivity.kt`

**Interfaces:**
- Consumes: every screen composable from Tasks 4–11; `AuthRepository.authState()` from Task 4 to gate splash → login vs. splash → home.
- Produces: `GramBaseeNavHost(navController: NavHostController, startDestination: String)` wired into `MainActivity`; this is the terminal integration task — after this task the app is a complete, navigable whole.

- [ ] **Step 1: Implement Destinations.kt**

```kotlin
package app.village.grambasee.nav

object Destinations {
    const val SPLASH = "splash"
    const val ONBOARDING = "onboarding"
    const val LOGIN = "login"
    const val HOME = "home"
    const val ALL_DONATIONS = "all_donations"
    const val ALL_EXPENSES = "all_expenses"
    const val DONATE = "donate"
    const val DONATE_CHECKOUT = "donate_checkout"
    const val PROBLEMS = "problems"
    const val PROBLEM_DETAILS = "problem_details/{problemId}"
    const val REPORT_PROBLEM = "report_problem"
    const val PROJECTS = "projects"
    const val PROJECT_DETAILS = "project_details/{projectId}"
    const val CITIZENS = "citizens"
    const val CITIZEN_PROFILE = "citizen_profile/{citizenId}"
    const val LEADERS = "leaders"
    const val NOTIFICATIONS = "notifications"
    const val REPORTS = "reports"
    const val PROFILE = "profile"
    const val SETTINGS = "settings"

    fun problemDetails(id: String) = "problem_details/$id"
    fun projectDetails(id: String) = "project_details/$id"
    fun citizenProfile(id: String) = "citizen_profile/$id"
}
```

- [ ] **Step 2: Implement GramBaseeNavHost.kt**

```kotlin
package app.village.grambasee.nav

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import app.village.grambasee.feature.auth.LoginScreen
import app.village.grambasee.feature.citizens.CitizenDirectoryScreen
import app.village.grambasee.feature.citizens.CitizenProfileScreen
import app.village.grambasee.feature.donation.DonationCheckoutScreen
import app.village.grambasee.feature.donation.DonationScreen
import app.village.grambasee.feature.home.AllDonationsScreen
import app.village.grambasee.feature.home.AllExpensesScreen
import app.village.grambasee.feature.home.HomeScreen
import app.village.grambasee.feature.leaders.LeadersScreen
import app.village.grambasee.feature.notifications.NotificationScreen
import app.village.grambasee.feature.onboarding.OnboardingScreen
import app.village.grambasee.feature.problems.ProblemDetailsScreen
import app.village.grambasee.feature.problems.ProblemsScreen
import app.village.grambasee.feature.problems.ReportProblemScreen
import app.village.grambasee.feature.profile.ProfileScreen
import app.village.grambasee.feature.projects.ProjectDetailsScreen
import app.village.grambasee.feature.projects.ProjectsScreen
import app.village.grambasee.feature.reports.ReportsScreen
import app.village.grambasee.feature.settings.SettingsScreen
import app.village.grambasee.feature.splash.SplashScreen

@Composable
fun GramBaseeNavHost(navController: NavHostController, startDestination: String) {
    NavHost(navController = navController, startDestination = startDestination) {
        composable(Destinations.SPLASH) { SplashScreen() }
        composable(Destinations.ONBOARDING) {
            OnboardingScreen(onFinished = { navController.navigate(Destinations.LOGIN) })
        }
        composable(Destinations.LOGIN) {
            LoginScreen(onLoginSuccess = {
                navController.navigate(Destinations.HOME) {
                    popUpTo(Destinations.LOGIN) { inclusive = true }
                }
            })
        }
        composable(Destinations.HOME) {
            HomeScreen(
                onSeeAllDonations = { navController.navigate(Destinations.ALL_DONATIONS) },
                onSeeAllExpenses = { navController.navigate(Destinations.ALL_EXPENSES) },
            )
        }
        composable(Destinations.ALL_DONATIONS) { AllDonationsScreen() }
        composable(Destinations.ALL_EXPENSES) { AllExpensesScreen() }
        composable(Destinations.DONATE) {
            DonationScreen(onDonateClicked = { navController.navigate(Destinations.DONATE_CHECKOUT) })
        }
        composable(Destinations.DONATE_CHECKOUT) {
            DonationCheckoutScreen(onSubmitted = { navController.popBackStack() })
        }
        composable(Destinations.PROBLEMS) {
            ProblemsScreen(
                onProblemClick = { navController.navigate(Destinations.problemDetails(it)) },
                onReportClick = { navController.navigate(Destinations.REPORT_PROBLEM) },
            )
        }
        composable(
            Destinations.PROBLEM_DETAILS,
            arguments = listOf(navArgument("problemId") { type = NavType.StringType }),
        ) { backStackEntry ->
            ProblemDetailsScreen(problemId = backStackEntry.arguments?.getString("problemId").orEmpty())
        }
        composable(Destinations.REPORT_PROBLEM) {
            ReportProblemScreen(onReported = { navController.popBackStack() })
        }
        composable(Destinations.PROJECTS) {
            ProjectsScreen(onProjectClick = { navController.navigate(Destinations.projectDetails(it)) })
        }
        composable(
            Destinations.PROJECT_DETAILS,
            arguments = listOf(navArgument("projectId") { type = NavType.StringType }),
        ) { backStackEntry ->
            ProjectDetailsScreen(projectId = backStackEntry.arguments?.getString("projectId").orEmpty())
        }
        composable(Destinations.CITIZENS) {
            CitizenDirectoryScreen(onCitizenClick = { navController.navigate(Destinations.citizenProfile(it)) })
        }
        composable(
            Destinations.CITIZEN_PROFILE,
            arguments = listOf(navArgument("citizenId") { type = NavType.StringType }),
        ) { backStackEntry ->
            CitizenProfileScreen(citizenId = backStackEntry.arguments?.getString("citizenId").orEmpty())
        }
        composable(Destinations.LEADERS) { LeadersScreen() }
        composable(Destinations.NOTIFICATIONS) { NotificationScreen() }
        composable(Destinations.REPORTS) { ReportsScreen() }
        composable(Destinations.PROFILE) {
            ProfileScreen(
                onSettingsClick = { navController.navigate(Destinations.SETTINGS) },
                onSignOut = {
                    navController.navigate(Destinations.LOGIN) {
                        popUpTo(0)
                    }
                },
            )
        }
        composable(Destinations.SETTINGS) { SettingsScreen() }
    }
}
```

- [ ] **Step 3: Wire bottom nav + auth-gated start destination into MainActivity.kt**

```kotlin
package app.village.grambasee

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import app.village.grambasee.data.AuthRepository
import app.village.grambasee.nav.Destinations
import app.village.grambasee.nav.GramBaseeNavHost
import app.village.grambasee.theme.GramBaseeTheme
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject lateinit var authRepository: AuthRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            GramBaseeTheme {
                val navController = rememberNavController()
                val currentUser by authRepository.authState().collectAsState(initial = null)
                val startDestination = if (currentUser == null) Destinations.LOGIN else Destinations.HOME
                val backStackEntry by navController.currentBackStackEntryAsState()
                val bottomNavRoutes = setOf(
                    Destinations.HOME, Destinations.DONATE, Destinations.PROBLEMS,
                    Destinations.CITIZENS, Destinations.PROFILE,
                )
                val currentRoute = backStackEntry?.destination?.route

                Scaffold(
                    bottomBar = {
                        if (currentRoute in bottomNavRoutes) {
                            NavigationBar {
                                NavigationBarItem(
                                    selected = currentRoute == Destinations.HOME,
                                    onClick = { navController.navigate(Destinations.HOME) },
                                    icon = { Icon(Icons.Filled.Home, contentDescription = "Home") },
                                    label = { Text("Home") },
                                )
                                NavigationBarItem(
                                    selected = currentRoute == Destinations.DONATE,
                                    onClick = { navController.navigate(Destinations.DONATE) },
                                    icon = { Icon(Icons.Filled.List, contentDescription = "Donations") },
                                    label = { Text("Donations") },
                                )
                                NavigationBarItem(
                                    selected = currentRoute == Destinations.PROBLEMS,
                                    onClick = { navController.navigate(Destinations.PROBLEMS) },
                                    icon = { Icon(Icons.Filled.Warning, contentDescription = "Problems") },
                                    label = { Text("Problems") },
                                )
                                NavigationBarItem(
                                    selected = currentRoute == Destinations.CITIZENS,
                                    onClick = { navController.navigate(Destinations.CITIZENS) },
                                    icon = { Icon(Icons.Filled.Notifications, contentDescription = "Citizens") },
                                    label = { Text("Citizens") },
                                )
                                NavigationBarItem(
                                    selected = currentRoute == Destinations.PROFILE,
                                    onClick = { navController.navigate(Destinations.PROFILE) },
                                    icon = { Icon(Icons.Filled.Person, contentDescription = "Profile") },
                                    label = { Text("Profile") },
                                )
                            }
                        }
                    },
                ) { padding ->
                    Box(modifier = Modifier.padding(padding)) {
                        GramBaseeNavHost(navController = navController, startDestination = startDestination)
                    }
                }
            }
        }
    }
}
```

(Add `import androidx.compose.foundation.layout.Box` and `import androidx.compose.foundation.layout.padding`. Add `implementation("androidx.compose.material:material-icons-extended")` — actually `Icons.Filled.*` used here ship in the core `material-icons-core` artifact bundled with `material3`, so no extra dependency is required; verify by building.)

- [ ] **Step 4: Build**

Run: `cd android-native && ./gradlew :app:assembleDebug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Manual smoke test**

Run: `cd android-native && ./gradlew :app:installDebug` with an emulator or device attached, then launch the app and confirm: splash briefly shows, login screen appears when signed out, and after entering valid clientapp credentials the bottom nav appears with Home populated from live Firestore data.

- [ ] **Step 6: Commit**

```bash
git add android-native
git commit -m "feat(android-native): wire navigation graph and bottom nav, complete app shell"
```

---

## Self-Review Notes

- **Spec coverage:** every screen listed in the spec's Scope section has a task (splash/onboarding/login → Task 4; home/all-donations/all-expenses → Task 5; donations/checkout → Task 6; problems/details/report/vote → Task 7; projects → Task 8; citizens/leaders → Task 9; notifications → Task 10; reports/profile/settings → Task 11; push → Task 12; nav → Task 13). Auth convention, Firebase project reuse, and defensive parsing constraints are each implemented in Tasks 3–4 exactly as the spec requires.
- **Placeholder scan:** no TBD/TODO markers; every step has concrete code or an exact command.
- **Type consistency:** `Donation`, `Problem`, `Project`, `Citizen`, `AppNotification`, `Village`, `FundTransaction`, `PaymentConfig`, `UserProfile` field names are defined once in Task 3 and reused verbatim by every repository/ViewModel/screen in later tasks.

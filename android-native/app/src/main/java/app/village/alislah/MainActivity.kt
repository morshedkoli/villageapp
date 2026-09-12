package app.village.alislah

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import android.content.Intent
import androidx.compose.runtime.mutableStateOf
import androidx.core.content.ContextCompat
import app.village.alislah.nav.AlIslahNavHost
import app.village.alislah.nav.Destinations
import app.village.alislah.push.PushNotificationManager
import app.village.alislah.theme.AlIslahTheme

class MainActivity : ComponentActivity() {

    private val pendingNavRoute = mutableStateOf<String?>(null)

    private val notificationPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            PushNotificationManager.subscribeToBroadcastTopic()
            PushNotificationManager.syncTokenToCurrentUser()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        handleNotificationIntent(intent)

        // Request POST_NOTIFICATIONS on Android 13+ (API 33+)
        checkAndRequestNotificationPermission()

        // Ensure token and topics are registered
        PushNotificationManager.initialize(this)

        setContent {
            AlIslahTheme {
                AlIslahNavHost(
                    pendingRoute = pendingNavRoute.value,
                    onRouteConsumed = { pendingNavRoute.value = null }
                )
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleNotificationIntent(intent)
    }

    private fun handleNotificationIntent(intent: Intent?) {
        if (intent == null) return
        val extras = intent.extras ?: return

        val title = extras.getString("title") ?: extras.getString("gcm.notification.title")
        val body = extras.getString("body") ?: extras.getString("gcm.notification.body")
        val type = extras.getString("type") ?: extras.getString("gcm.notification.type")
        val targetId = extras.getString("targetId")
            ?: extras.getString("problemId")
            ?: extras.getString("projectId")
            ?: extras.getString("donationId")
            ?: extras.getString("id")
            ?: extras.getString("notificationId")
        val customRoute = extras.getString("route") ?: extras.getString("click_action")

        val targetRoute = Destinations.resolveNotificationRoute(
            type = type,
            targetId = targetId,
            customRoute = customRoute,
            title = title,
            body = body
        ) ?: if (extras.containsKey("id") || extras.containsKey("notificationId") || !type.isNullOrBlank()) {
            Destinations.NOTIFICATIONS
        } else null

        android.util.Log.d("MainActivity", "Notification intent received -> targetRoute: $targetRoute")

        if (targetRoute != null) {
            pendingNavRoute.value = targetRoute
        }
    }

    private fun checkAndRequestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val hasPermission = ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED

            if (!hasPermission) {
                notificationPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
            }
        }
    }
}

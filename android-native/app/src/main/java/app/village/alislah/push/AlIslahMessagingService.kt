package app.village.alislah.push

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class AlIslahMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "AlIslahFCM"
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        PushNotificationManager.subscribeToBroadcastTopic()
        PushNotificationManager.syncTokenToCurrentUser()
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        val title = (remoteMessage.notification?.title ?: remoteMessage.data["title"] ?: "").trim()
        val body = (remoteMessage.notification?.body ?: remoteMessage.data["body"] ?: "").trim()

        if (title.isBlank() && body.isBlank()) {
            return
        }

        // Deduplication Check
        val messageId = remoteMessage.messageId
            ?: remoteMessage.data["id"]
            ?: remoteMessage.data["notificationId"]
            ?: "${title}_${body}"

        if (PushNotificationManager.isDuplicateMessage(messageId)) {
            Log.d(TAG, "Duplicate FCM message dropped: $messageId")
            return
        }

        // If the FCM message contains a 'notification' payload AND the app is in the background,
        // Google Play Services / Android OS automatically builds and displays the notification tray item.
        // We only trigger manual display if the app is in the FOREGROUND, or for pure DATA payloads.
        val hasNotificationPayload = remoteMessage.notification != null
        val isForeground = PushNotificationManager.isAppInForeground()

        if (hasNotificationPayload && !isForeground) {
            Log.d(TAG, "Notification payload handled by system tray for background app")
            return
        }

        val type = remoteMessage.data["type"] ?: "broadcast"
        val channelId = when (type.lowercase()) {
            "donation", "fund" -> PushNotificationManager.CHANNEL_DONATIONS
            "problem", "issue", "complaint" -> PushNotificationManager.CHANNEL_PROBLEMS
            "project", "development" -> PushNotificationManager.CHANNEL_PROJECTS
            else -> PushNotificationManager.CHANNEL_BROADCAST
        }

        PushNotificationManager.showHeadsUpNotification(
            context = applicationContext,
            title = title.ifBlank { "গ্রামবাসী বিজ্ঞপ্তি" },
            body = body,
            channelId = channelId,
            data = remoteMessage.data
        )
    }
}

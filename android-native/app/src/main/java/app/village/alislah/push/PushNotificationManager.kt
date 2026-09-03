package app.village.alislah.push

import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import app.village.alislah.MainActivity
import app.village.alislah.R
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import java.util.concurrent.ConcurrentHashMap
import kotlin.math.abs

object PushNotificationManager {
    private const val TAG = "PushNotificationManager"

    // Single canonical topic matching backend Cloud Functions (BROADCAST_TOPIC = 'village_broadcast')
    const val BROADCAST_TOPIC = "village_broadcast"

    // Channels
    const val CHANNEL_BROADCAST = "village_broadcast"
    const val CHANNEL_DONATIONS = "village_donations"
    const val CHANNEL_PROBLEMS = "village_problems"
    const val CHANNEL_PROJECTS = "village_projects"

    // Deduplication cache: stores message key -> timestamp (milliseconds)
    private val processedMessages = ConcurrentHashMap<String, Long>()
    private const val DEDUP_WINDOW_MS = 15_000L // 15 seconds

    fun initialize(context: Context) {
        createNotificationChannels(context)
        subscribeToBroadcastTopic()
        syncTokenToCurrentUser()
    }

    private fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()

            val broadcastChannel = NotificationChannel(
                CHANNEL_BROADCAST,
                "গ্রামের সাধারণ ও জরুরি বিজ্ঞপ্তি",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "সকল গ্রামবাসীর সাধারণ ও জরুরি ঘোষণা"
                enableLights(true)
                lightColor = Color.GREEN
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 150, 250)
                setSound(defaultSoundUri, audioAttributes)
            }

            val donationsChannel = NotificationChannel(
                CHANNEL_DONATIONS,
                "তহবিল ও অনুদান সংক্রান্ত বিজ্ঞপ্তি",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "নতুন অনুদান প্রাপ্তি ও তহবিলের হিসাব সংক্রান্ত নোটিফিকেশন"
                enableLights(true)
                lightColor = Color.YELLOW
                enableVibration(true)
                setSound(defaultSoundUri, audioAttributes)
            }

            val problemsChannel = NotificationChannel(
                CHANNEL_PROBLEMS,
                "অভিযোগ ও সমস্যা সমাধান বিজ্ঞপ্তি",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "গ্রামের সমস্যা সমাধান ও আপডেট নোটিফিকেশন"
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
                setSound(defaultSoundUri, audioAttributes)
            }

            val projectsChannel = NotificationChannel(
                CHANNEL_PROJECTS,
                "উন্নয়ন প্রকল্পের অগ্রগতি বিজ্ঞপ্তি",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "গ্রাম উন্নয়ন প্রকল্পের নতুন অগ্রগতি ও বাজেট আপডেট"
                enableLights(true)
                lightColor = Color.CYAN
                enableVibration(true)
                setSound(defaultSoundUri, audioAttributes)
            }

            notificationManager.createNotificationChannels(
                listOf(broadcastChannel, donationsChannel, problemsChannel, projectsChannel)
            )
        }
    }

    fun subscribeToBroadcastTopic() {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                // Subscribe to single canonical broadcast topic
                FirebaseMessaging.getInstance().subscribeToTopic(BROADCAST_TOPIC).await()
                Log.d(TAG, "Subscribed successfully to: $BROADCAST_TOPIC")

                // Unsubscribe from any redundant legacy topics to avoid double delivery
                val legacyTopics = listOf("all", "announcements", "donations", "problems", "projects", "village_updates")
                for (legacy in legacyTopics) {
                    try {
                        FirebaseMessaging.getInstance().unsubscribeFromTopic(legacy).await()
                    } catch (_: Exception) {}
                }
            } catch (e: Exception) {
                Log.w(TAG, "Failed to subscribe to $BROADCAST_TOPIC", e)
            }
        }
    }

    fun syncTokenToCurrentUser() {
        val user = FirebaseAuth.getInstance().currentUser ?: return
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val token = FirebaseMessaging.getInstance().token.await()
                if (token.isNotBlank()) {
                    val userDoc = FirebaseFirestore.getInstance().collection("users").document(user.uid)
                    userDoc.update(
                        mapOf(
                            "fcmToken" to token,
                            "fcmTokens" to FieldValue.arrayUnion(token),
                            "lastTokenUpdate" to FieldValue.serverTimestamp()
                        )
                    ).await()
                    Log.d(TAG, "FCM token synced for user: ${user.uid}")
                }
            } catch (e: Exception) {
                Log.w(TAG, "Could not sync FCM token to Firestore", e)
            }
        }
    }

    /**
     * Checks if this notification has already been processed within the dedup window.
     */
    fun isDuplicateMessage(messageKey: String): Boolean {
        val now = System.currentTimeMillis()
        // Clean up old entries
        processedMessages.entries.removeIf { now - it.value > DEDUP_WINDOW_MS }

        val lastSeen = processedMessages[messageKey]
        if (lastSeen != null && now - lastSeen < DEDUP_WINDOW_MS) {
            return true
        }
        processedMessages[messageKey] = now
        return false
    }

    /**
     * Helper to check if the app is currently visible/in the foreground.
     */
    fun isAppInForeground(): Boolean {
        return try {
            val appProcessInfo = ActivityManager.RunningAppProcessInfo()
            ActivityManager.getMyMemoryState(appProcessInfo)
            appProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND ||
                    appProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_VISIBLE
        } catch (_: Exception) {
            false
        }
    }

    fun showHeadsUpNotification(
        context: Context,
        title: String,
        body: String,
        channelId: String = CHANNEL_BROADCAST,
        data: Map<String, String> = emptyMap()
    ) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create deterministic notification ID and Tag to prevent duplicates
        val notifTag = data["id"] ?: data["notificationId"] ?: data["type"] ?: "village_notif"
        val notifId = abs((title.trim().hashCode() * 31) + body.trim().hashCode())

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            for ((k, v) in data) {
                putExtra(k, v)
            }
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            notifId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setAutoCancel(true)
            .setSound(soundUri)
            .setVibrate(longArrayOf(0, 250, 150, 250))
            .setContentIntent(pendingIntent)

        notificationManager.notify(notifTag, notifId, builder.build())
    }
}

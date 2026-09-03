package app.village.alislah

import android.app.Application
import app.village.alislah.push.PushNotificationManager
import com.google.firebase.FirebaseApp
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreSettings

class AlIslahApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)

        // Enable Firestore offline persistence & caching (up to 100MB)
        try {
            val db = FirebaseFirestore.getInstance()
            val settings = FirebaseFirestoreSettings.Builder()
                .setPersistenceEnabled(true)
                .setCacheSizeBytes(100L * 1024 * 1024)
                .build()
            db.firestoreSettings = settings
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Initialize Push Notification channels and topic subscriptions for all users
        try {
            PushNotificationManager.initialize(this)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}

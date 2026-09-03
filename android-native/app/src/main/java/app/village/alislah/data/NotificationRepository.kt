package app.village.alislah.data

import app.village.alislah.model.AppNotification
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await

class NotificationRepository(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    private val notificationsCollection = firestore.collection("notifications")

    fun getNotificationsFlow(userId: String? = null): Flow<List<AppNotification>> = callbackFlow {
        val query = notificationsCollection
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(100)

        val registration = query.addSnapshotListener { snapshot, error ->
            if (error != null) {
                trySend(emptyList())
                return@addSnapshotListener
            }
            if (snapshot != null) {
                val notifications = snapshot.documents.map { doc ->
                    AppNotification.fromMap(doc.id, doc.data)
                }
                trySend(notifications)
            } else {
                trySend(emptyList())
            }
        }
        awaitClose { registration.remove() }
    }

    suspend fun markAsRead(notificationId: String, userId: String): Result<Unit> = runCatching {
        if (userId.isEmpty()) return@runCatching
        firestore.collection("users")
            .document(userId)
            .collection("notification_reads")
            .document(notificationId)
            .set(mapOf("readAt" to FieldValue.serverTimestamp()))
            .await()
    }
}

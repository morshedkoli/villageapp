package app.village.alislah.data

import app.village.alislah.model.AppNotification
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.tasks.await

class NotificationRepository(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    private val notificationsCollection = firestore.collection("notifications")

    /**
     * Broadcast notifications, each tagged with whether this user has already
     * read it. Read state lives in `users/{uid}/notification_reads/{id}` —
     * without folding it back in here every notification stays bold forever
     * and the home badge counts the whole list.
     */
    fun getNotificationsFlow(userId: String? = null): Flow<List<AppNotification>> {
        val reads = if (userId.isNullOrEmpty()) flowOf(emptySet()) else readIdsFlow(userId)
        return combine(notificationDocsFlow(), reads) { notifications, readIds ->
            notifications.map { it.copy(isRead = readIds.contains(it.id)) }
        }
    }

    private fun notificationDocsFlow(): Flow<List<AppNotification>> = callbackFlow {
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

    private fun readIdsFlow(userId: String): Flow<Set<String>> = callbackFlow {
        val registration = firestore.collection("users")
            .document(userId)
            .collection("notification_reads")
            .addSnapshotListener { snapshot, error ->
                if (error != null || snapshot == null) {
                    trySend(emptySet())
                    return@addSnapshotListener
                }
                trySend(snapshot.documents.map { it.id }.toSet())
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

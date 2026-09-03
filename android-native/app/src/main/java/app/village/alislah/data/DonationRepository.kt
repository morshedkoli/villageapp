package app.village.alislah.data

import app.village.alislah.model.Donation
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await

class DonationRepository(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    private val donationsCollection = firestore.collection("donations")

    fun getDonationsFlow(limit: Long = 100): Flow<List<Donation>> = callbackFlow {
        val query = donationsCollection
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(limit)

        val registration = query.addSnapshotListener { snapshot, error ->
            if (error != null) {
                trySend(emptyList())
                return@addSnapshotListener
            }
            if (snapshot != null) {
                val donations = snapshot.documents.map { doc ->
                    Donation.fromMap(doc.id, doc.data)
                }
                trySend(donations)
            } else {
                trySend(emptyList())
            }
        }
        awaitClose { registration.remove() }
    }

    suspend fun submitDonation(donation: Donation): Result<String> = runCatching {
        val data = donation.toMap().toMutableMap()
        data["createdAt"] = FieldValue.serverTimestamp()
        data["status"] = "Pending"

        val docRef = donationsCollection.add(data).await()
        docRef.id
    }
}

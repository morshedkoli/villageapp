package app.village.alislah.data

import app.village.alislah.model.Citizen
import app.village.alislah.model.Leader
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow

class CitizenRepository(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    fun getCitizensFlow(): Flow<List<Citizen>> = callbackFlow {
        val query = firestore.collection("users")
            .whereEqualTo("isCitizen", true)
            .limit(200)

        val registration = query.addSnapshotListener { snapshot, error ->
            if (error != null) {
                trySend(emptyList())
                return@addSnapshotListener
            }
            if (snapshot != null) {
                val citizens = snapshot.documents
                    .map { doc -> Citizen.fromMap(doc.id, doc.data) }
                    .filter { !it.blocked }
                    .sortedBy { it.name }
                trySend(citizens)
            } else {
                trySend(emptyList())
            }
        }
        awaitClose { registration.remove() }
    }

    fun getLeadersFlow(): Flow<List<Leader>> = callbackFlow {
        val query = firestore.collection("leaders")
            .limit(50)

        val registration = query.addSnapshotListener { snapshot, error ->
            // An empty list renders the screen's empty state. Never substitute
            // placeholder committee members: villagers read them as the real
            // names and phone numbers of people they can call.
            if (error != null || snapshot == null) {
                trySend(emptyList())
                return@addSnapshotListener
            }

            val leaders = snapshot.documents.map { doc ->
                Leader.fromMap(doc.id, doc.data)
            }.sortedBy { it.priority }

            trySend(leaders)
        }
        awaitClose { registration.remove() }
    }
}

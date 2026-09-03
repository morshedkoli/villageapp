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
            if (error != null || snapshot == null || snapshot.isEmpty) {
                // Fallback: create mock committee leaders if collection not yet populated
                val fallbackLeaders = listOf(
                    Leader(
                        id = "l1",
                        name = "মোঃ আব্দুল কাদের",
                        designation = "গ্রাম সভাপতি",
                        phone = "01711000000",
                        description = "গ্রাম উন্নয়ন কমিটির সম্মানিত সভাপতি"
                    ),
                    Leader(
                        id = "l2",
                        name = "ড. মোর্শেদ আলী",
                        designation = "সাধারণ সম্পাদক",
                        phone = "01811000000",
                        description = "উন্নয়ন ও অর্থ তদারকি সমন্বয়ক"
                    ),
                    Leader(
                        id = "l3",
                        name = "তাহমিনা বেগম",
                        designation = "মহিলা বিষয়ক সম্পাদিকা",
                        phone = "01911000000",
                        description = "নারী ও শিশু কল্যাণ বিষয়ক উপদেষ্টা"
                    )
                )
                trySend(fallbackLeaders)
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

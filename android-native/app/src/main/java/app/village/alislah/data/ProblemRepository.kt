package app.village.alislah.data

import app.village.alislah.model.Problem
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await

class ProblemRepository(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    private val problemsCollection = firestore.collection("problems")

    fun getProblemsFlow(currentUserId: String? = null, limit: Long = 100): Flow<List<Problem>> = callbackFlow {
        val query = problemsCollection
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(limit)

        val registration = query.addSnapshotListener { snapshot, error ->
            if (error != null) {
                trySend(emptyList())
                return@addSnapshotListener
            }
            if (snapshot != null) {
                val problems = snapshot.documents.map { doc ->
                    Problem.fromMap(doc.id, doc.data)
                }
                trySend(problems)
            } else {
                trySend(emptyList())
            }
        }
        awaitClose { registration.remove() }
    }

    suspend fun reportProblem(problem: Problem): Result<String> = runCatching {
        val data = problem.toMap().toMutableMap()
        data["createdAt"] = FieldValue.serverTimestamp()
        data["status"] = "Pending"
        data["upvotesCount"] = 0

        val docRef = problemsCollection.add(data).await()
        docRef.id
    }

    suspend fun toggleVote(problemId: String, userId: String): Result<Boolean> = runCatching {
        val voteDocRef = problemsCollection.document(problemId).collection("votes").document(userId)
        val problemDocRef = problemsCollection.document(problemId)

        val voteSnap = voteDocRef.get().await()
        val hasVoted = voteSnap.exists()

        if (hasVoted) {
            voteDocRef.delete().await()
            problemDocRef.update("upvotesCount", FieldValue.increment(-1)).await()
            false
        } else {
            voteDocRef.set(mapOf("createdAt" to FieldValue.serverTimestamp())).await()
            problemDocRef.update("upvotesCount", FieldValue.increment(1)).await()
            true
        }
    }

    suspend fun hasUserVoted(problemId: String, userId: String): Boolean {
        return try {
            val voteSnap = problemsCollection.document(problemId).collection("votes").document(userId).get().await()
            voteSnap.exists()
        } catch (e: Exception) {
            false
        }
    }
}

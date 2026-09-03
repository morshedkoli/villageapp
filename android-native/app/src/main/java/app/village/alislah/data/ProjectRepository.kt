package app.village.alislah.data

import app.village.alislah.model.Project
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow

class ProjectRepository(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    private val projectsCollection = firestore.collection("projects")

    fun getProjectsFlow(): Flow<List<Project>> = callbackFlow {
        val query = projectsCollection
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(100)

        val registration = query.addSnapshotListener { snapshot, error ->
            if (error != null) {
                trySend(emptyList())
                return@addSnapshotListener
            }
            if (snapshot != null) {
                val projects = snapshot.documents.map { doc ->
                    Project.fromMap(doc.id, doc.data)
                }
                trySend(projects)
            } else {
                trySend(emptyList())
            }
        }
        awaitClose { registration.remove() }
    }

    fun getProjectFlow(projectId: String): Flow<Project?> = callbackFlow {
        val docRef = projectsCollection.document(projectId)
        val registration = docRef.addSnapshotListener { snapshot, error ->
            if (error != null || snapshot == null || !snapshot.exists()) {
                trySend(null)
                return@addSnapshotListener
            }
            trySend(Project.fromMap(snapshot.id, snapshot.data))
        }
        awaitClose { registration.remove() }
    }
}

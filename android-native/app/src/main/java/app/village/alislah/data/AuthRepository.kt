package app.village.alislah.data

import app.village.alislah.model.UserProfile
import com.google.firebase.auth.AuthCredential
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await

class AuthRepository(
    private val auth: FirebaseAuth = FirebaseAuth.getInstance(),
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    val currentUser: FirebaseUser?
        get() = auth.currentUser

    val currentUserId: String?
        get() = auth.currentUser?.uid

    val authStateFlow: Flow<FirebaseUser?> = callbackFlow {
        val listener = FirebaseAuth.AuthStateListener { firebaseAuth ->
            trySend(firebaseAuth.currentUser)
        }
        auth.addAuthStateListener(listener)
        awaitClose { auth.removeAuthStateListener(listener) }
    }

    fun getUserProfileFlow(uid: String): Flow<UserProfile?> = callbackFlow {
        val docRef = firestore.collection("users").document(uid)
        val registration = docRef.addSnapshotListener { snapshot, error ->
            if (error != null) {
                trySend(null)
                return@addSnapshotListener
            }
            if (snapshot != null && snapshot.exists()) {
                trySend(UserProfile.fromMap(snapshot.id, snapshot.data))
            } else {
                trySend(null)
            }
        }
        awaitClose { registration.remove() }
    }

    private fun normalizePhone(phone: String): String {
        val digitsOnly = phone.replace(Regex("[^0-9]"), "")
        return if (digitsOnly.startsWith("880")) {
            digitsOnly.substring(2)
        } else if (digitsOnly.startsWith("0")) {
            digitsOnly.substring(1)
        } else {
            digitsOnly
        }
    }

    private fun phoneToSyntheticEmail(phone: String): String {
        val normalized = normalizePhone(phone)
        return "p$normalized@village.app"
    }

    suspend fun signInWithPhone(phone: String, password: String):Result<FirebaseUser> = runCatching {
        val email = phoneToSyntheticEmail(phone)
        val result = auth.signInWithEmailAndPassword(email, password).await()
        result.user ?: throw Exception("Authentication returned null user")
    }

    suspend fun signUpWithPhone(
        phone: String,
        password: String,
        name: String,
        village: String = "গ্রামবাসী",
        profession: String = ""
    ): Result<FirebaseUser> = runCatching {
        val email = phoneToSyntheticEmail(phone)
        val result = auth.createUserWithEmailAndPassword(email, password).await()
        val user = result.user ?: throw Exception("Registration returned null user")

        // Upsert user profile in Firestore
        val profile = UserProfile(
            id = user.uid,
            name = name,
            phone = phone,
            email = user.email ?: "",
            village = village,
            profession = profession,
            isCitizen = true
        )
        firestore.collection("users").document(user.uid)
            .set(profile.toMap(), SetOptions.merge())
            .await()

        user
    }

    suspend fun signInWithEmail(email: String, password: String): Result<FirebaseUser> = runCatching {
        val result = auth.signInWithEmailAndPassword(email.trim(), password).await()
        result.user ?: throw Exception("Authentication returned null user")
    }

    suspend fun signUpWithEmail(
        email: String,
        password: String,
        name: String,
        phone: String = "",
        village: String = "গ্রামবাসী"
    ): Result<FirebaseUser> = runCatching {
        val result = auth.createUserWithEmailAndPassword(email.trim(), password).await()
        val user = result.user ?: throw Exception("Registration returned null user")

        val profile = UserProfile(
            id = user.uid,
            name = name,
            phone = phone,
            email = email.trim(),
            village = village,
            isCitizen = true
        )
        firestore.collection("users").document(user.uid)
            .set(profile.toMap(), SetOptions.merge())
            .await()

        user
    }

    suspend fun signInWithGoogleCredential(idToken: String): Result<FirebaseUser> = runCatching {
        val credential = GoogleAuthProvider.getCredential(idToken, null)
        val result = auth.signInWithCredential(credential).await()
        val user = result.user ?: throw Exception("Google Sign-In returned null user")

        // Upsert profile for new Google user if missing
        val docRef = firestore.collection("users").document(user.uid)
        val snap = docRef.get().await()
        if (!snap.exists()) {
            val profile = UserProfile(
                id = user.uid,
                name = user.displayName ?: "Google User",
                email = user.email ?: "",
                photoUrl = user.photoUrl?.toString() ?: "",
                isCitizen = true
            )
            docRef.set(profile.toMap(), SetOptions.merge()).await()
        }

        app.village.alislah.push.PushNotificationManager.syncTokenToCurrentUser()
        app.village.alislah.push.PushNotificationManager.subscribeToBroadcastTopic()

        user
    }

    suspend fun updateUserProfile(profile: UserProfile): Result<Unit> = runCatching {
        val uid = currentUserId ?: throw Exception("User not logged in")
        firestore.collection("users").document(uid)
            .set(profile.toMap(), SetOptions.merge())
            .await()
    }

    fun signOut() {
        auth.signOut()
    }
}

package app.village.alislah.data

import app.village.alislah.model.PaymentAccount
import app.village.alislah.model.Village
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow

class VillageRepository(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    private val villageDocRef = firestore.collection("villages").document("main_village")

    fun getVillageFlow(): Flow<Village> = callbackFlow {
        val registration = villageDocRef.addSnapshotListener { snapshot, error ->
            if (error != null) {
                trySend(Village())
                return@addSnapshotListener
            }
            if (snapshot != null && snapshot.exists()) {
                trySend(Village.fromMap(snapshot.id, snapshot.data))
            } else {
                trySend(Village())
            }
        }
        awaitClose { registration.remove() }
    }

    @Suppress("UNCHECKED_CAST")
    fun getPaymentAccountsFlow(): Flow<List<PaymentAccount>> = callbackFlow {
        val registration = villageDocRef.addSnapshotListener { snapshot, error ->
            if (error != null || snapshot == null || !snapshot.exists()) {
                trySend(emptyList())
                return@addSnapshotListener
            }

            val data = snapshot.data
            val raw = data?.get("paymentAccounts")
            val accounts = mutableListOf<PaymentAccount>()

            if (raw is List<*>) {
                for (item in raw) {
                    if (item is Map<*, *>) {
                        accounts.add(PaymentAccount.fromMap(item as Map<String, Any?>))
                    }
                }
            } else if (raw is Map<*, *>) {
                for ((_, item) in raw) {
                    if (item is Map<*, *>) {
                        accounts.add(PaymentAccount.fromMap(item as Map<String, Any?>))
                    }
                }
            }

            trySend(accounts)
        }
        awaitClose { registration.remove() }
    }
}

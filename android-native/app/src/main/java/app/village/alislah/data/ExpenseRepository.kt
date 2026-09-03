package app.village.alislah.data

import app.village.alislah.model.FundTransaction
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow

class ExpenseRepository(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) {
    private val fundTransactionsCollection = firestore.collection("fund_transactions")

    fun getExpensesFlow(limit: Long = 100): Flow<List<FundTransaction>> = callbackFlow {
        val query = fundTransactionsCollection
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(limit)

        val registration = query.addSnapshotListener { snapshot, error ->
            if (error != null) {
                trySend(emptyList())
                return@addSnapshotListener
            }
            if (snapshot != null) {
                val expenses = snapshot.documents
                    .map { doc -> FundTransaction.fromMap(doc.id, doc.data) }
                    .filter { it.isExpense }
                trySend(expenses)
            } else {
                trySend(emptyList())
            }
        }
        awaitClose { registration.remove() }
    }
}

package app.village.alislah.data

import android.util.Log
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
        // Query fund_transactions ordered by createdAt DESC (no composite index required)
        // and filter by type == "expense" in memory.
        val query = fundTransactionsCollection
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .limit(limit)

        val registration = query.addSnapshotListener { snapshot, error ->
            if (error != null) {
                Log.w("ExpenseRepository", "Query with orderBy failed: ${error.message}. Trying fallback without order.", error)
                // Fallback: listen without ordering if orderBy has any issues with missing fields
                val fallbackReg = fundTransactionsCollection.limit(limit).addSnapshotListener { fbSnap, fbErr ->
                    if (fbErr != null) {
                        Log.e("ExpenseRepository", "Fallback query also failed: ${fbErr.message}", fbErr)
                        trySend(emptyList())
                        return@addSnapshotListener
                    }
                    if (fbSnap != null) {
                        val expenses = fbSnap.documents
                            .map { doc -> FundTransaction.fromMap(doc.id, doc.data) }
                            .filter { it.isExpense }
                            .sortedByDescending { it.createdAt }
                        trySend(expenses)
                    } else {
                        trySend(emptyList())
                    }
                }
                return@addSnapshotListener
            }

            if (snapshot != null) {
                val expenses = snapshot.documents
                    .map { doc -> FundTransaction.fromMap(doc.id, doc.data) }
                    .filter { it.isExpense }
                Log.d("ExpenseRepository", "Fetched ${expenses.size} expenses from ${snapshot.size()} documents")
                trySend(expenses)
            } else {
                trySend(emptyList())
            }
        }
        awaitClose { registration.remove() }
    }
}

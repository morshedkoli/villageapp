package app.village.alislah.model

import app.village.alislah.core.Parsing
import java.util.Date

data class Donation(
    val id: String = "",
    val donorName: String = "",
    val amount: Double = 0.0,
    val paymentMethod: String = "bKash",
    val receivedAccountId: String = "",
    val receivedAccountLabel: String = "",
    val transactionId: String = "",
    val senderNumber: String = "",
    val status: String = "Pending", // "Pending", "Approved", "Rejected"
    val userId: String = "",
    val createdAt: Date = Date(),
    val notes: String = ""
) {
    val isApproved: Boolean
        get() = status.equals("Approved", ignoreCase = true)

    val isPending: Boolean
        get() = status.equals("Pending", ignoreCase = true)

    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?): Donation {
            return Donation(
                id = id,
                donorName = Parsing.readString(map, "donorName", "Anonymous"),
                amount = Parsing.readDouble(map, "amount", 0.0),
                paymentMethod = Parsing.readString(map, "paymentMethod", "bKash"),
                receivedAccountId = Parsing.readString(map, "receivedAccountId", ""),
                receivedAccountLabel = Parsing.readString(map, "receivedAccountLabel", ""),
                transactionId = Parsing.readString(map, "transactionId", ""),
                senderNumber = Parsing.readString(map, "senderNumber", ""),
                status = Parsing.readString(map, "status", "Pending"),
                userId = Parsing.readString(map, "userId", ""),
                createdAt = Parsing.readDate(map, "createdAt"),
                notes = Parsing.readString(map, "notes", "")
            )
        }
    }

    fun toMap(): Map<String, Any?> {
        return mapOf(
            "donorName" to donorName,
            "amount" to amount,
            "paymentMethod" to paymentMethod,
            "receivedAccountId" to receivedAccountId,
            "receivedAccountLabel" to receivedAccountLabel,
            "transactionId" to transactionId,
            "senderNumber" to senderNumber,
            "status" to status,
            "userId" to userId,
            "notes" to notes
        )
    }
}

package app.village.alislah.model

import app.village.alislah.core.Parsing
import java.util.Date

data class FundTransaction(
    val id: String = "",
    val type: String = "expense", // "donation" or "expense"
    val amount: Double = 0.0,
    val reference: String = "",
    val project: String = "",
    val category: String = "",
    val notes: String = "",
    val createdAt: Date = Date()
) {
    val isExpense: Boolean
        get() = type.equals("expense", ignoreCase = true)

    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?): FundTransaction {
            return FundTransaction(
                id = id,
                type = Parsing.readString(map, "type", "expense"),
                amount = Parsing.readDouble(map, "amount", 0.0),
                reference = Parsing.readString(map, "reference", ""),
                project = Parsing.readString(map, "project", Parsing.readString(map, "reference", "General")),
                category = Parsing.readString(map, "category", "Other"),
                notes = Parsing.readString(map, "notes", ""),
                createdAt = Parsing.readDate(map, "createdAt")
            )
        }
    }
}

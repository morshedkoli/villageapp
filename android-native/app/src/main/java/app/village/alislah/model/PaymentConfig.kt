package app.village.alislah.model

import app.village.alislah.core.Parsing

data class PaymentAccount(
    val id: String = "",
    val type: String = "bkash", // "bkash", "nagad", "rocket", "bank"
    val number: String = "",
    val name: String = "",
    val branch: String = "",
    val routing: String = ""
) {
    val displayType: String
        get() = when (type.lowercase()) {
            "bkash" -> "বিকাশ (bKash)"
            "nagad" -> "নগদ (Nagad)"
            "rocket" -> "রকেট (Rocket)"
            "bank" -> "ব্যাংক একাউন্ট"
            else -> type.replaceFirstChar { it.uppercase() }
        }

    companion object {
        fun fromMap(map: Map<String, Any?>?): PaymentAccount {
            return PaymentAccount(
                id = Parsing.readString(map, "id", ""),
                type = Parsing.readString(map, "type", "bkash"),
                number = Parsing.readString(map, "number", ""),
                name = Parsing.readString(map, "name", ""),
                branch = Parsing.readString(map, "branch", ""),
                routing = Parsing.readString(map, "routing", "")
            )
        }
    }
}

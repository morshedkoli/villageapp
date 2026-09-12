package app.village.alislah.model

import app.village.alislah.core.Parsing

/**
 * The single `villages/main_village` document. Only the counters the admin
 * panel and Cloud Functions actually maintain live here — a field nothing
 * writes renders as a permanent zero in the UI.
 */
data class Village(
    val id: String = "main_village",
    val name: String = "গ্রামবাসী",
    val totalCitizens: Int = 0,
    val totalFundCollected: Double = 0.0,
    val totalSpent: Double = 0.0
) {
    val availableBalance: Double
        get() = (totalFundCollected - totalSpent).coerceAtLeast(0.0)

    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?): Village {
            return Village(
                id = id,
                name = Parsing.readString(map, "name", "গ্রামবাসী"),
                totalCitizens = Parsing.readInt(map, "totalCitizens", 0),
                totalFundCollected = Parsing.readDouble(map, "totalFundCollected", 0.0),
                totalSpent = Parsing.readDouble(map, "totalSpent", 0.0)
            )
        }
    }
}

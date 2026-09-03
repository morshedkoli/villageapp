package app.village.alislah.model

import app.village.alislah.core.Parsing

data class Village(
    val id: String = "main_village",
    val name: String = "গ্রামবাসী",
    val totalCitizens: Int = 0,
    val totalFundCollected: Double = 0.0,
    val totalSpent: Double = 0.0,
    val emergencyFund: Double = 0.0,
    val activeProjectsCount: Int = 0
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
                totalSpent = Parsing.readDouble(map, "totalSpent", 0.0),
                emergencyFund = Parsing.readDouble(map, "emergencyFund", 0.0),
                activeProjectsCount = Parsing.readInt(map, "activeProjectsCount", 0)
            )
        }
    }
}

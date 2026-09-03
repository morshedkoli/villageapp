package app.village.alislah.model

import app.village.alislah.core.Parsing
import java.util.Date

data class Project(
    val id: String = "",
    val title: String = "",
    val description: String = "",
    val estimatedCost: Double = 0.0,
    val allocatedFunds: Double = 0.0,
    val status: String = "Planning", // "Planning", "In Progress", "Completed"
    val photos: List<String> = emptyList(),
    val updates: List<String> = emptyList(),
    val spendingReport: List<String> = emptyList(),
    val createdAt: Date = Date()
) {
    val progressPercentage: Float
        get() = if (estimatedCost > 0) {
            ((allocatedFunds / estimatedCost) * 100).toFloat().coerceIn(0f, 100f)
        } else {
            0f
        }

    val isCompleted: Boolean
        get() = status.equals("Completed", ignoreCase = true)

    val isInProgress: Boolean
        get() = status.equals("In Progress", ignoreCase = true)

    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?): Project {
            return Project(
                id = id,
                title = Parsing.readString(map, "title", ""),
                description = Parsing.readString(map, "description", ""),
                estimatedCost = Parsing.readDouble(map, "estimatedCost", 0.0),
                allocatedFunds = Parsing.readDouble(map, "allocatedFunds", 0.0),
                status = Parsing.readString(map, "status", "Planning"),
                photos = Parsing.readStringList(map, "photos"),
                updates = Parsing.readStringList(map, "updates"),
                spendingReport = Parsing.readStringList(map, "spendingReport"),
                createdAt = Parsing.readDate(map, "createdAt")
            )
        }
    }
}

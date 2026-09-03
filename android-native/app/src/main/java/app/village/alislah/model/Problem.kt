package app.village.alislah.model

import app.village.alislah.core.Parsing
import java.util.Date

data class Problem(
    val id: String = "",
    val title: String = "",
    val description: String = "",
    val photoUrl: String = "",
    val location: String = "",
    val status: String = "Pending", // "Pending", "Approved", "Completed"
    val reportedBy: String = "",
    val reportedByName: String = "",
    val createdAt: Date = Date(),
    val upvotesCount: Int = 0,
    val hasVoted: Boolean = false
) {
    val isPending: Boolean
        get() = status.equals("Pending", ignoreCase = true)

    val isApproved: Boolean
        get() = status.equals("Approved", ignoreCase = true)

    val isCompleted: Boolean
        get() = status.equals("Completed", ignoreCase = true)

    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?, hasVoted: Boolean = false): Problem {
            return Problem(
                id = id,
                title = Parsing.readString(map, "title", ""),
                description = Parsing.readString(map, "description", ""),
                photoUrl = Parsing.readString(map, "photoUrl", ""),
                location = Parsing.readString(map, "location", ""),
                status = Parsing.readString(map, "status", "Pending"),
                reportedBy = Parsing.readString(map, "reportedBy", ""),
                reportedByName = Parsing.readString(map, "reportedByName", "Anonymous"),
                createdAt = Parsing.readDate(map, "createdAt"),
                upvotesCount = Parsing.readInt(map, "upvotesCount", Parsing.readInt(map, "votesCount", 0)),
                hasVoted = hasVoted
            )
        }
    }

    fun toMap(): Map<String, Any?> {
        return mapOf(
            "title" to title,
            "description" to description,
            "photoUrl" to photoUrl,
            "location" to location,
            "status" to status,
            "reportedBy" to reportedBy,
            "reportedByName" to reportedByName,
            "upvotesCount" to upvotesCount
        )
    }
}

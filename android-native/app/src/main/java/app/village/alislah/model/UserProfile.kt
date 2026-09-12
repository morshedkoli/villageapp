package app.village.alislah.model

import app.village.alislah.core.Parsing
import java.util.Date

data class UserProfile(
    val id: String = "",
    val name: String = "",
    val phone: String = "",
    val email: String = "",
    val photoUrl: String = "",
    val profession: String = "",
    val village: String = "",
    val address: String = "",
    val nidNumber: String = "",
    val bloodGroup: String = "",
    val dateOfBirth: String = "",
    val isCitizen: Boolean = true,
    val isAdmin: Boolean = false,
    val blocked: Boolean = false,
    val createdAt: Date = Date()
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?): UserProfile {
            return UserProfile(
                id = id,
                name = Parsing.readString(map, "name", ""),
                phone = Parsing.readString(map, "phone", ""),
                email = Parsing.readString(map, "email", ""),
                photoUrl = Parsing.readString(map, "photoUrl", ""),
                profession = Parsing.readString(map, "profession", ""),
                village = Parsing.readString(map, "village", ""),
                address = Parsing.readString(map, "address", ""),
                nidNumber = Parsing.readString(map, "nidNumber", ""),
                bloodGroup = Parsing.readString(map, "bloodGroup", ""),
                dateOfBirth = Parsing.readString(map, "dateOfBirth", ""),
                isCitizen = Parsing.readBoolean(map, "isCitizen", true),
                isAdmin = Parsing.readBoolean(map, "isAdmin", false),
                blocked = Parsing.readBoolean(map, "blocked", false),
                createdAt = Parsing.readDate(map, "createdAt")
            )
        }
    }

    /**
     * Fields this app is allowed to write for a signed-in user. `isAdmin` and
     * `blocked` are deliberately absent: they are admin-controlled, and
     * firestore.rules rejects any client update that touches them.
     */
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "name" to name,
            "phone" to phone,
            "email" to email,
            "photoUrl" to photoUrl,
            "profession" to profession,
            "village" to village,
            "address" to address,
            "nidNumber" to nidNumber,
            "bloodGroup" to bloodGroup,
            "dateOfBirth" to dateOfBirth,
            "isCitizen" to isCitizen
        )
    }

    /**
     * The subset a citizen edits on the profile screen. Writing only these
     * keys keeps `phone`, `email` and `createdAt` intact — a full [toMap]
     * merge from a freshly built instance blanked them.
     */
    fun toEditableMap(): Map<String, Any?> {
        return mapOf(
            "name" to name,
            "photoUrl" to photoUrl,
            "profession" to profession,
            "village" to village,
            "address" to address,
            "nidNumber" to nidNumber,
            "bloodGroup" to bloodGroup,
            "dateOfBirth" to dateOfBirth
        )
    }
}

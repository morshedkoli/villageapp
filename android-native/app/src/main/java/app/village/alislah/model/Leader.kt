package app.village.alislah.model

import app.village.alislah.core.Parsing

data class Leader(
    val id: String = "",
    val name: String = "",
    val designation: String = "",
    val phone: String = "",
    val email: String = "",
    val photoUrl: String = "",
    val description: String = "",
    val priority: Int = 0
) {
    companion object {
        fun fromMap(id: String, map: Map<String, Any?>?): Leader {
            return Leader(
                id = id,
                name = Parsing.readString(map, "name", "Leader"),
                designation = Parsing.readString(map, "designation", Parsing.readString(map, "role", "কমিটি সদস্য")),
                phone = Parsing.readString(map, "phone", ""),
                email = Parsing.readString(map, "email", ""),
                photoUrl = Parsing.readString(map, "photoUrl", ""),
                description = Parsing.readString(map, "description", ""),
                priority = Parsing.readInt(map, "priority", 0)
            )
        }
    }
}

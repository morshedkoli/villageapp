package app.village.alislah.di

import app.village.alislah.data.AuthRepository
import app.village.alislah.data.CitizenRepository
import app.village.alislah.data.DonationRepository
import app.village.alislah.data.ExpenseRepository
import app.village.alislah.data.NotificationRepository
import app.village.alislah.data.ProblemRepository
import app.village.alislah.data.ProjectRepository
import app.village.alislah.data.VillageRepository
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore

object ServiceLocator {
    val auth: FirebaseAuth by lazy { FirebaseAuth.getInstance() }
    val firestore: FirebaseFirestore by lazy { FirebaseFirestore.getInstance() }

    val authRepository: AuthRepository by lazy {
        AuthRepository(auth, firestore)
    }

    val villageRepository: VillageRepository by lazy {
        VillageRepository(firestore)
    }

    val donationRepository: DonationRepository by lazy {
        DonationRepository(firestore)
    }

    val expenseRepository: ExpenseRepository by lazy {
        ExpenseRepository(firestore)
    }

    val problemRepository: ProblemRepository by lazy {
        ProblemRepository(firestore)
    }

    val projectRepository: ProjectRepository by lazy {
        ProjectRepository(firestore)
    }

    val citizenRepository: CitizenRepository by lazy {
        CitizenRepository(firestore)
    }

    val notificationRepository: NotificationRepository by lazy {
        NotificationRepository(firestore)
    }
}

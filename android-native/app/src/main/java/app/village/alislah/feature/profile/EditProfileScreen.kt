package app.village.alislah.feature.profile

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Badge
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.InvertColors
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Work
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import app.village.alislah.components.ButtonVariant
import app.village.alislah.components.AlIslahButton
import app.village.alislah.components.AlIslahTextField
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.data.AuthRepository
import app.village.alislah.di.ServiceLocator
import app.village.alislah.model.UserProfile
import app.village.alislah.theme.AlIslahTheme
import kotlinx.coroutines.launch

@Composable
fun EditProfileScreen(
    onBackClick: () -> Unit,
    authRepository: AuthRepository = ServiceLocator.authRepository
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()
    val currentUid = authRepository.currentUserId

    var name by remember { mutableStateOf("") }
    var profession by remember { mutableStateOf("") }
    var village by remember { mutableStateOf("") }
    var address by remember { mutableStateOf("") }
    var bloodGroup by remember { mutableStateOf("") }
    var nidNumber by remember { mutableStateOf("") }
    var photoUrl by remember { mutableStateOf("") }
    var isSaving by remember { mutableStateOf(false) }

    LaunchedEffect(currentUid) {
        if (currentUid != null) {
            authRepository.getUserProfileFlow(currentUid).collect { profile ->
                if (profile != null) {
                    name = profile.name
                    profession = profile.profession
                    village = profile.village
                    address = profile.address
                    bloodGroup = profile.bloodGroup
                    nidNumber = profile.nidNumber
                    photoUrl = profile.photoUrl
                }
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
            .navigationBarsPadding()
            .imePadding()
    ) {
        AlIslahTopBar(
            title = "প্রোফাইল সম্পাদনা",
            showBackButton = true,
            onBackClick = onBackClick
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(20.dp)
        ) {
            AlIslahTextField(
                value = name,
                onValueChange = { name = it },
                modifier = Modifier.fillMaxWidth(),
                label = "আপনার পূর্ণ নাম *",
                placeholder = "নাম লিখুন",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = profession,
                onValueChange = { profession = it },
                modifier = Modifier.fillMaxWidth(),
                label = "পেশা / পদবী",
                placeholder = "যেমন: শিক্ষক / ব্যবসায়ী / প্রবাসী",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Work,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = village,
                onValueChange = { village = it },
                modifier = Modifier.fillMaxWidth(),
                label = "গ্রাম / পাড়ার নাম",
                placeholder = "গ্রামের নাম লিখুন",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Home,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = address,
                onValueChange = { address = it },
                modifier = Modifier.fillMaxWidth(),
                label = "বর্তমান ঠিকানা",
                placeholder = "ঠিকানা লিখুন",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Home,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = bloodGroup,
                onValueChange = { bloodGroup = it },
                modifier = Modifier.fillMaxWidth(),
                label = "রক্তের গ্রুপ",
                placeholder = "যেমন: A+, B+, O+, AB+",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.InvertColors,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = nidNumber,
                onValueChange = { nidNumber = it },
                modifier = Modifier.fillMaxWidth(),
                label = "জাতীয় পরিচয়পত্র নম্বর (NID)",
                placeholder = "NID নম্বর",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Badge,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = photoUrl,
                onValueChange = { photoUrl = it },
                modifier = Modifier.fillMaxWidth(),
                label = "প্রোফাইল ছবির লিংক (ঐচ্ছিক)",
                placeholder = "https://example.com/avatar.jpg",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Image,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                }
            )

            Spacer(modifier = Modifier.height(28.dp))

            AlIslahButton(
                text = "তথ্য সংরক্ষণ করুন",
                onClick = {
                    if (name.isBlank()) {
                        Toast.makeText(context, "নাম খালি রাখা যাবে না", Toast.LENGTH_SHORT).show()
                        return@AlIslahButton
                    }
                    isSaving = true
                    coroutineScope.launch {
                        val updatedProfile = UserProfile(
                            id = currentUid ?: "",
                            name = name.trim(),
                            profession = profession.trim(),
                            village = village.trim(),
                            address = address.trim(),
                            bloodGroup = bloodGroup.trim(),
                            nidNumber = nidNumber.trim(),
                            photoUrl = photoUrl.trim()
                        )
                        val result = authRepository.updateUserProfile(updatedProfile)
                        isSaving = false
                        result.fold(
                            onSuccess = {
                                Toast.makeText(context, "প্রোফাইল সফলভাবে আপডেট হয়েছে!", Toast.LENGTH_SHORT).show()
                                onBackClick()
                            },
                            onFailure = { error ->
                                Toast.makeText(context, error.localizedMessage ?: "আপডেট ব্যর্থ হয়েছে", Toast.LENGTH_SHORT).show()
                            }
                        )
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                isLoading = isSaving,
                variant = ButtonVariant.PRIMARY
            )

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

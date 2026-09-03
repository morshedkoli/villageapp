package app.village.alislah.feature.auth

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material.icons.filled.Work
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.components.ButtonVariant
import app.village.alislah.components.GoogleSignInButton
import app.village.alislah.components.AlIslahButton
import app.village.alislah.components.AlIslahCard
import app.village.alislah.components.AlIslahTextField
import app.village.alislah.components.AlIslahTopBar
import app.village.alislah.components.OrDivider
import app.village.alislah.data.GoogleAuthHelper
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInStatusCodes
import com.google.android.gms.common.api.ApiException

@Composable
fun RegisterScreen(
    onRegisterSuccess: () -> Unit,
    onNavigateToLogin: () -> Unit,
    viewModel: LoginViewModel = viewModel()
) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsState()

    var name by remember { mutableStateOf("") }
    var identifier by remember { mutableStateOf("") }
    var village by remember { mutableStateOf("গ্রামবাসী") }
    var profession by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    val googleSignInClient = remember(context) {
        GoogleAuthHelper.getGoogleSignInClient(context)
    }

    val googleLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
        try {
            val account = task.getResult(ApiException::class.java)
            val idToken = account.idToken
            if (idToken != null) {
                viewModel.signInWithGoogle(idToken)
            } else {
                viewModel.setErrorMessage("গুগল আইডি টোকেন পাওয়া যায়নি")
            }
        } catch (e: ApiException) {
            if (e.statusCode != GoogleSignInStatusCodes.SIGN_IN_CANCELLED) {
                val message = when (e.statusCode) {
                    12500 -> "গুগল প্লে সার্ভিস আপডেট প্রয়োজন"
                    7 -> "ইন্টারনেট সংযোগ সমস্যা (Network error)"
                    else -> "গুগল সাইন-ইন ব্যর্থ হয়েছে (কোড: ${e.statusCode})"
                }
                viewModel.setErrorMessage(message)
            }
        }
    }

    LaunchedEffect(uiState.successUser) {
        if (uiState.successUser != null) {
            onRegisterSuccess()
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
            title = "নাগরিক নিবন্ধন",
            showBackButton = true,
            onBackClick = onNavigateToLogin
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Google One-Tap Register Button
            GoogleSignInButton(
                text = "Google দিয়ে সরাসরি নিবন্ধন করুন",
                onClick = {
                    googleSignInClient.signOut().addOnCompleteListener {
                        googleLauncher.launch(googleSignInClient.signInIntent)
                    }
                },
                isLoading = uiState.isLoading
            )

            Spacer(modifier = Modifier.height(20.dp))

            OrDivider(text = "অথবা নিচের তথ্য পূরণ করুন")

            Spacer(modifier = Modifier.height(20.dp))

            // Mode toggle
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(AlIslahTheme.customColors.cardBorder.copy(alpha = 0.5f))
                    .padding(4.dp)
            ) {
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(10.dp))
                        .background(
                            if (uiState.isPhoneMode) AlIslahTheme.customColors.cardBackground
                            else Color.Transparent
                        )
                        .clickable { if (!uiState.isPhoneMode) viewModel.toggleAuthMode() }
                        .padding(vertical = 10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "মোবাইল নাম্বার",
                        style = MaterialTheme.typography.labelLarge.copy(
                            fontWeight = if (uiState.isPhoneMode) FontWeight.Bold else FontWeight.Medium
                        ),
                        color = if (uiState.isPhoneMode) AlIslahPrimary else AlIslahTheme.customColors.textSecondary
                    )
                }

                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(10.dp))
                        .background(
                            if (!uiState.isPhoneMode) AlIslahTheme.customColors.cardBackground
                            else Color.Transparent
                        )
                        .clickable { if (uiState.isPhoneMode) viewModel.toggleAuthMode() }
                        .padding(vertical = 10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "ইমেইল এড্রেস",
                        style = MaterialTheme.typography.labelLarge.copy(
                            fontWeight = if (!uiState.isPhoneMode) FontWeight.Bold else FontWeight.Medium
                        ),
                        color = if (!uiState.isPhoneMode) AlIslahPrimary else AlIslahTheme.customColors.textSecondary
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            AlIslahTextField(
                value = name,
                onValueChange = { name = it },
                modifier = Modifier.fillMaxWidth(),
                label = "আপনার পূর্ণ নাম *",
                placeholder = "যেমন: মোঃ রফিকুল ইসলাম",
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
                value = identifier,
                onValueChange = { identifier = it },
                modifier = Modifier.fillMaxWidth(),
                label = if (uiState.isPhoneMode) "মোবাইল নাম্বার *" else "ইমেইল এড্রেস *",
                placeholder = if (uiState.isPhoneMode) "017XXXXXXXX" else "user@example.com",
                leadingIcon = {
                    Icon(
                        imageVector = if (uiState.isPhoneMode) Icons.Default.Phone else Icons.Default.Email,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                },
                keyboardOptions = KeyboardOptions(
                    keyboardType = if (uiState.isPhoneMode) KeyboardType.Phone else KeyboardType.Email
                )
            )

            Spacer(modifier = Modifier.height(14.dp))

            AlIslahTextField(
                value = profession,
                onValueChange = { profession = it },
                modifier = Modifier.fillMaxWidth(),
                label = "পেশা / পদবী",
                placeholder = "যেমন: শিক্ষক / ব্যবসায়ী / কৃষক",
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
                label = "গ্রাম / পাড়া",
                placeholder = "যেমন: উত্তর পাড়া",
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
                value = password,
                onValueChange = { password = it },
                modifier = Modifier.fillMaxWidth(),
                label = "পাসওয়ার্ড (কমপক্ষে ৬ অক্ষর) *",
                placeholder = "••••••••",
                leadingIcon = {
                    Icon(
                        imageVector = Icons.Default.Lock,
                        contentDescription = null,
                        tint = AlIslahTheme.customColors.textSecondary
                    )
                },
                trailingIcon = {
                    IconButton(onClick = { viewModel.togglePasswordVisibility() }) {
                        Icon(
                            imageVector = if (uiState.isPasswordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                            contentDescription = "Toggle password visibility",
                            tint = AlIslahTheme.customColors.textSecondary
                        )
                    }
                },
                visualTransformation = if (uiState.isPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password)
            )

            // Error message if any
            if (uiState.errorMessage != null) {
                Spacer(modifier = Modifier.height(12.dp))
                AlIslahCard(
                    backgroundColor = AlIslahTheme.customColors.statusRejectedBg,
                    borderColor = Color.Transparent
                ) {
                    Text(
                        text = uiState.errorMessage ?: "",
                        style = MaterialTheme.typography.bodyMedium,
                        color = AlIslahTheme.customColors.statusRejectedFg
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Submit Button
            AlIslahButton(
                text = "একাউন্ট তৈরি করুন",
                onClick = {
                    viewModel.signUp(
                        name = name,
                        identifier = identifier,
                        password = password,
                        village = village,
                        profession = profession
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                isLoading = uiState.isLoading,
                variant = ButtonVariant.PRIMARY
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Login Prompt
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "ইতিমধ্যে একাউন্ট আছে? ",
                    style = MaterialTheme.typography.bodyMedium,
                    color = AlIslahTheme.customColors.textSecondary
                )
                Text(
                    text = "লগইন করুন",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = AlIslahPrimary
                    ),
                    modifier = Modifier.clickable { onNavigateToLogin() }
                )
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

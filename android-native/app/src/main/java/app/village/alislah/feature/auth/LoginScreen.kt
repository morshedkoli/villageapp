package app.village.alislah.feature.auth

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Campaign
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Construction
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.VolunteerActivism
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import app.village.alislah.R
import app.village.alislah.components.GoogleSignInButton
import app.village.alislah.components.AlIslahCard
import app.village.alislah.data.GoogleAuthHelper
import app.village.alislah.theme.CardShape
import app.village.alislah.theme.AlIslahPrimary
import app.village.alislah.theme.AlIslahTheme
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInStatusCodes
import com.google.android.gms.common.api.ApiException

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit = {},
    viewModel: LoginViewModel = viewModel()
) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsState()

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
                    10 -> "OAuth কনফিগারেশন চেকিং: Firebase কনসোলে SHA-1 যোগ করুন"
                    else -> "গুগল সাইন-ইন ব্যর্থ হয়েছে (কোড: ${e.statusCode})"
                }
                viewModel.setErrorMessage(message)
            }
        }
    }

    LaunchedEffect(uiState.successUser) {
        if (uiState.successUser != null) {
            onLoginSuccess()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
            .navigationBarsPadding()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 24.dp, vertical = 20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.fillMaxWidth()
        ) {
            Spacer(modifier = Modifier.height(24.dp))

            // App Icon with subtle elevation & squircle clipping
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .shadow(elevation = 12.dp, shape = RoundedCornerShape(26.dp), spotColor = AlIslahPrimary.copy(alpha = 0.4f))
                    .clip(RoundedCornerShape(26.dp))
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                Image(
                    painter = painterResource(id = R.drawable.app_logo),
                    contentDescription = "Al Islah Logo",
                    modifier = Modifier.fillMaxSize()
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            Text(
                text = "Al Islah",
                style = MaterialTheme.typography.headlineLarge.copy(
                    fontWeight = FontWeight.ExtraBold,
                    fontSize = 30.sp,
                    letterSpacing = 0.5.sp
                ),
                color = AlIslahTheme.customColors.textPrimary
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = "গ্রামের ঐক্য, স্বচ্ছতা ও টেকসই উন্নয়নের প্ল্যাটফর্ম",
                style = MaterialTheme.typography.bodyMedium,
                color = AlIslahTheme.customColors.textSecondary,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(32.dp))

            // App Value Proposition Cards
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                FeatureHighlightRow(
                    icon = Icons.Default.VolunteerActivism,
                    iconTint = AlIslahPrimary,
                    title = "স্বচ্ছ অনুদান ও তহবিল",
                    description = "প্রতিটি অনুদান ও ব্যয়ের পাই-পাই হিসাব সবার জন্য উন্মুক্ত"
                )

                FeatureHighlightRow(
                    icon = Icons.Default.Construction,
                    iconTint = Color(0xFF0EA5E9),
                    title = "উন্নয়ন প্রকল্পের ট্র্যাকিং",
                    description = "গ্রামের চলমান ও ভবিষ্যৎ কাজের লাইভ অগ্রগতি ও বাজেট"
                )

                FeatureHighlightRow(
                    icon = Icons.Default.Campaign,
                    iconTint = Color(0xFFF59E0B),
                    title = "নাগরিক সমস্যা ও মতামত",
                    description = "রাস্তাঘাট, বিদ্যুৎ ও জরুরি সমস্যার দ্রুত সমাধান ও ভোটিং"
                )
            }

            Spacer(modifier = Modifier.height(28.dp))

            // Error display if any
            if (uiState.errorMessage != null) {
                AlIslahCard(
                    backgroundColor = AlIslahTheme.customColors.statusRejectedBg,
                    borderColor = Color.Transparent,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = uiState.errorMessage ?: "",
                        style = MaterialTheme.typography.bodyMedium,
                        color = AlIslahTheme.customColors.statusRejectedFg,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                Spacer(modifier = Modifier.height(16.dp))
            }
        }

        // Bottom Call to Action
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp)
        ) {
            // Google Sign-In Only Button
            GoogleSignInButton(
                text = "Google দিয়ে এক ক্লিকে সাইন-ইন করুন",
                onClick = {
                    googleSignInClient.signOut().addOnCompleteListener {
                        googleLauncher.launch(googleSignInClient.signInIntent)
                    }
                },
                isLoading = uiState.isLoading
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Shield,
                    contentDescription = null,
                    tint = AlIslahPrimary,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "গুগল একাউন্ট দিয়ে ১০০% সুরক্ষিত সাইন-ইন",
                    style = MaterialTheme.typography.labelSmall,
                    color = AlIslahTheme.customColors.textTertiary
                )
            }
        }
    }
}

@Composable
private fun FeatureHighlightRow(
    icon: ImageVector,
    iconTint: Color,
    title: String,
    description: String
) {
    AlIslahCard(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(iconTint.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = iconTint,
                    modifier = Modifier.size(24.dp)
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold),
                    color = AlIslahTheme.customColors.textPrimary
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = description,
                    style = MaterialTheme.typography.bodySmall,
                    color = AlIslahTheme.customColors.textSecondary,
                    lineHeight = 16.sp
                )
            }
        }
    }
}

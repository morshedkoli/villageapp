part of '../screens.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return _SidebarPageScaffold(
      title: tr('Profile', 'প্রোফাইল'),
      subtitle: tr(
        'Manage account details and accessibility preferences',
        'অ্যাকাউন্ট ও এক্সেসিবিলিটি পছন্দগুলো পরিচালনা করুন',
      ),
      selectedId: _MenuId.profile,
      actions: const [_NotificationButton()],
      body: StreamBuilder(
        stream: data.authState(),
        builder: (context, _) {
          final user = data.currentUser;
          return _constrainBodyWidth(
            context,
            ListView(
              padding: _pagePadding(
                context,
              ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
              children: [
                if (user == null)
                  AppCard(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primaryC(context).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primaryC(context),
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr('Welcome!', 'স্বাগতম!'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.textPrimaryC(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr(
                            'Login to access all features',
                            'সব ফিচার ব্যবহার করতে লগইন করুন',
                          ),
                          style: TextStyle(
                            color: AppColors.textSecondaryC(context),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          label: tr('Login', 'লগইন'),
                        ),
                      ],
                    ),
                  )
                else
                  AppCard(
                    child: Column(
                      children: [
                        user.photoURL != null
                            ? CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(user.photoURL!),
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.primaryC(context).withValues(
                                  alpha: 0.08,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primaryC(context),
                                  size: 40,
                                ),
                              ),
                        const SizedBox(height: 12),
                        Text(
                          user.displayName ??
                              user.email?.split('@').first ??
                              tr('Citizen', 'নাগরিক'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.textPrimaryC(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? '',
                          style: TextStyle(
                            color: AppColors.textSecondaryC(context),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final profile = await DataService.instance
                                      .getUserProfile();
                                  if (!context.mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProfileSetupScreen(
                                        existingProfile: profile,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: Text(
                                  tr('Edit Profile', 'প্রোফাইল সম্পাদনা'),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryC(context),
                                  side: BorderSide(
                                    color: AppColors.borderLightC(context),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PrimaryButton(
                                onPressed: data.signOut,
                                icon: Icons.logout_rounded,
                                label: tr('Logout', 'লগআউট'),
                                gradient: AppColors.errorGradient,
                                fullWidth: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  tr('Preferences', 'পছন্দসমূহ').toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.textSecondaryC(context),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: accessibilityController,
                  builder: (context, AccessibilitySettings settings, _) {
                    return AppCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeThumbColor: AppColors.primaryC(context),
                            title: Text(
                              tr('High contrast mode', 'উচ্চ কনট্রাস্ট মোড'),
                              style: TextStyle(
                                color: AppColors.textPrimaryC(context),
                              ),
                            ),
                            value: settings.highContrast,
                            onChanged: accessibilityController.setHighContrast,
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              tr('Language', 'ভাষা'),
                              style: TextStyle(
                                color: AppColors.textPrimaryC(context),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SegmentedButton<String>(
                                  showSelectedIcon: false,
                                  selected: {settings.languageCode},
                                  onSelectionChanged: (v) =>
                                      accessibilityController.setLanguageCode(
                                        v.first,
                                      ),
                                  segments: const [
                                    ButtonSegment(
                                      value: 'en',
                                      label: Text('English'),
                                    ),
                                    ButtonSegment(
                                      value: 'bn',
                                      label: Text('বাংলা'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              tr('Theme', 'থিম'),
                              style: TextStyle(
                                color: AppColors.textPrimaryC(context),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SegmentedButton<ThemeMode>(
                                showSelectedIcon: false,
                                selected: {settings.themeMode},
                                onSelectionChanged: (v) =>
                                    accessibilityController.setThemeMode(v.first),
                                segments: const [
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    label: Text('System'),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    label: Text('Light'),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    label: Text('Dark'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Bottom sheet for editing the citizen's own profile.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../services/auth_service.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? profile;
  final User? firebaseUser;

  const EditProfileSheet({super.key, 
    required this.profile,
    required this.firebaseUser,
  });

  @override
  ConsumerState<EditProfileSheet> createState() => EditProfileSheetState();
}

class EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _professionController;
  late final TextEditingController _villageController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _nidController;
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _dobController;
  late final TextEditingController _passwordController;

  bool _saving = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile ?? {};
    final fUser = widget.firebaseUser;

    final initialName = profile['name'] as String? ?? fUser?.displayName ?? '';
    final initialEmail = profile['email'] as String? ?? (fUser?.email?.endsWith('@village.app') == true ? '' : fUser?.email) ?? '';
    final initialPhone = profile['phone'] as String? ?? '';
    final initialProfession = profile['profession'] as String? ?? '';
    final initialVillage = profile['village'] as String? ?? '';
    final initialAddress = profile['address'] as String? ?? '';
    final initialNid = profile['nidNumber'] as String? ?? '';
    final initialBlood = profile['bloodGroup'] as String? ?? '';
    final initialDob = profile['dateOfBirth'] as String? ?? '';

    _nameController = TextEditingController(text: initialName);
    _phoneController = TextEditingController(text: initialPhone);
    _professionController = TextEditingController(text: initialProfession);
    _villageController = TextEditingController(text: initialVillage);
    _emailController = TextEditingController(text: initialEmail);
    _addressController = TextEditingController(text: initialAddress);
    _nidController = TextEditingController(text: initialNid);
    _bloodGroupController = TextEditingController(text: initialBlood);
    _dobController = TextEditingController(text: initialDob);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _villageController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _nidController.dispose();
    _bloodGroupController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isPhoneLogin => widget.firebaseUser?.email?.endsWith('@village.app') == true;
  bool get _phoneChanged => _phoneController.text.trim() != (widget.profile?['phone'] as String? ?? '');

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final profession = _professionController.text.trim();
      final village = _villageController.text.trim();
      final email = _emailController.text.trim();
      final address = _addressController.text.trim();
      final nid = _nidController.text.trim();
      final blood = _bloodGroupController.text.trim();
      final dob = _dobController.text.trim();
      final password = _passwordController.text.trim();

      // If phone login user and phone changed, we need to update phone via Auth first
      if (_isPhoneLogin && _phoneChanged) {
        if (password.isEmpty) {
          throw StateError('ফোন নম্বর পরিবর্তন করতে পাসওয়ার্ড প্রয়োজন।');
        }
        await AuthService.instance.updateUserPhone(phone, password);
      }

      // Always update the general profile in Firestore
      await AuthService.instance.updateUserProfile(
        name: name,
        phone: phone,
        profession: profession,
        village: village,
        address: address,
        email: email,
        nidNumber: nid,
        bloodGroup: blood,
        dateOfBirth: dob,
      );

      // Invalidate providers to trigger rebuild of UI with new data
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(currentFirebaseUserProvider);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('প্রোফাইল সফলভাবে আপডেট করা হয়েছে'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('আপডেট ব্যর্থ: ${e.toString().replaceFirst('Exception: ', '').replaceFirst('Bad state: ', '')}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textTheme = context.textTheme;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Pull handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'প্রোফাইল সম্পাদনা',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Scrollable Fields
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      // Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'পূর্ণ নাম',
                        hint: 'যেমন: মোহাম্মদ রহিম',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'নাম লিখুন' : null,
                      ),
                      AppSpacing.hLg,

                      // Profession
                      _buildTextField(
                        controller: _professionController,
                        label: 'পেশা',
                        hint: 'যেমন: শিক্ষক, ব্যবসায়ী, ছাত্র',
                        icon: Icons.work_outline_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'পেশা লিখুন' : null,
                      ),
                      AppSpacing.hLg,

                      // Phone
                      _buildTextField(
                        controller: _phoneController,
                        label: 'ফোন নম্বর',
                        hint: 'যেমন: ০১৭XXXXXXXX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'ফোন নম্বর লিখুন' : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      AppSpacing.hLg,

                      // Village
                      _buildTextField(
                        controller: _villageController,
                        label: 'গ্রাম',
                        hint: 'যেমন: ইছাপুরা',
                        icon: Icons.holiday_village_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'গ্রামের নাম লিখুন' : null,
                      ),
                      AppSpacing.hLg,

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'ইমেইল (ঐচ্ছিক)',
                        hint: 'যেমন: email@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                            if (!emailPattern.hasMatch(v.trim())) {
                              return 'সঠিক ইমেইল ঠিকানা দিন';
                            }
                          }
                          return null;
                        },
                      ),
                      AppSpacing.hLg,

                      // Address
                      _buildTextField(
                        controller: _addressController,
                        label: 'ঠিকানা (ঐচ্ছিক)',
                        hint: 'গ্রাম, ডাকঘর, উপজেলা, জেলা',
                        icon: Icons.map_outlined,
                        maxLines: 2,
                      ),
                      AppSpacing.hLg,

                      // NID Number
                      _buildTextField(
                        controller: _nidController,
                        label: 'জাতীয় পরিচয়পত্র নম্বর (ঐচ্ছিক)',
                        hint: 'NID নম্বর',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      AppSpacing.hLg,

                      // Blood Group
                      _buildTextField(
                        controller: _bloodGroupController,
                        label: 'রক্তের গ্রুপ (ঐচ্ছিক)',
                        hint: 'যেমন: A+, O-, B+',
                        icon: Icons.bloodtype_outlined,
                      ),
                      AppSpacing.hLg,

                      // Date of Birth
                      _buildTextField(
                        controller: _dobController,
                        label: 'জন্ম তারিখ (ঐচ্ছিক)',
                        hint: 'YYYY-MM-DD',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.datetime,
                      ),
                      AppSpacing.hLg,

                      // Password section if phone user changes phone number
                      if (_isPhoneLogin && _phoneChanged) ...[
                        const Divider(),
                        AppSpacing.hMd,
                        Text(
                          'ফোন নম্বর পরিবর্তনের জন্য পাসওয়ার্ড লিখুন',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.hSm,
                        _buildTextField(
                          controller: _passwordController,
                          label: 'পাসওয়ার্ড',
                          hint: 'আপনার পাসওয়ার্ড লিখুন',
                          icon: Icons.lock_outline_rounded,
                          obscureText: !_showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                              color: context.textTertiary,
                            ),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'পাসওয়ার্ড লিখুন' : null,
                        ),
                        AppSpacing.hLg,
                      ],
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Save button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _saving ? null : _handleSave,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'সংরক্ষণ করুন',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final isDark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.hXs,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          onChanged: onChanged,
          style: context.textTheme.bodyMedium?.copyWith(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.textTheme.bodyMedium?.copyWith(color: context.textTertiary),
            prefixIcon: Icon(icon, size: 20, color: context.textTertiary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? AppColors.darkCard : AppColors.lightCanvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// Opens the profile editor as a modal bottom sheet.
void showEditProfileSheet(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic>? profile,
  User? firebaseUser,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditProfileSheet(
      profile: profile,
      firebaseUser: firebaseUser,
    ),
  );
}

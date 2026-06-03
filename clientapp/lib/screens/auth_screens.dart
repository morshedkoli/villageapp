part of '../screens.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _loading = false;
  late final AnimationController _animController;
  late final AnimationController _floatController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<Offset> _floatAnim;
  late final Animation<Offset> _orb1Anim;
  late final Animation<Offset> _orb2Anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
        );
        
    _floatAnim = Tween<Offset>(begin: const Offset(0, -0.02), end: const Offset(0, 0.02))
        .animate(
          CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
        );
    
    _orb1Anim = Tween<Offset>(begin: const Offset(0, -0.05), end: const Offset(0, 0.05))
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine));
        
    _orb2Anim = Tween<Offset>(begin: const Offset(0, 0.05), end: const Offset(0, -0.05))
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine));

    _animController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compact = size.width <= 360;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: _pageBackdrop(
              safeArea: false,
              child: const SizedBox.expand(),
            ),
          ),
          // Blurry Orbs for Glassmorphism pop
          Positioned(
            top: size.height * 0.05,
            left: -size.width * 0.2,
            child: SlideTransition(
              position: _orb1Anim,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryC(context).withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            right: -size.width * 0.2,
            child: SlideTransition(
              position: _orb2Anim,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: _constrainBodyWidth(
              context,
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 28),
child: FadeTransition(
               opacity: _fadeIn,
               child: SlideTransition(
                 position: _slideUp,
                 child: Column(
                   children: [
                     const SizedBox(height: 12),
                     // Back button
                     Align(
                       alignment: Alignment.centerLeft,
                       child: Material(
                         color: Colors.transparent,
                         child: InkWell(
                           onTap: () => Navigator.of(context).pop(),
                           borderRadius: BorderRadius.circular(AppRadius.md),
                           child: Container(
                             width: 38,
                             height: 38,
                             alignment: Alignment.center,
                             decoration: BoxDecoration(
                               color: AppColors.surfaceC(context),
                               borderRadius: BorderRadius.circular(AppRadius.md),
                               border: Border.all(color: AppColors.borderC(context)),
                             ),
                             child: Icon(
                               Icons.arrow_back_rounded,
                               color: AppColors.textPrimaryC(context),
                               size: 18,
                             ),
                           ),
                         ),
                       ),
                     ),
                     SizedBox(height: size.height * 0.03),
                     // Lottie Animation with continuous floating motion
                     SlideTransition(
                       position: _floatAnim,
                       child: Center(
                         child: Container(
                           height: 260,
                           constraints: const BoxConstraints(maxWidth: 280),
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             gradient: RadialGradient(
                               colors: [
                                 AppColors.primaryC(context).withValues(alpha: 0.15),
                                 Colors.transparent,
                               ],
                             ),
                           ),
                           child: Lottie.asset(
                             'assets/login_animation.json',
                             fit: BoxFit.contain,
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(height: 32),
                    Text(
                      tr('Welcome to AL ISLAH', 'আল ইসলাহ-এ স্বাগতম'),
                      style: AppTextStyles.headlineLarge.copyWith(
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr(
                        'Sign in to your village community',
                        'আপনার গ্রাম কমিউনিটিতে সাইন ইন করুন',
                      ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondaryC(context),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),
                    // Glassmorphic Login card
                    SlideTransition(
                      position: Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.015)).animate(_floatController),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryC(context).withValues(alpha: 0.15),
                                  blurRadius: 40,
                                  spreadRadius: -10,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  tr('Sign in to continue', 'চালিয়ে যেতে সাইন ইন করুন'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryC(context),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Google Sign-In button
                                PrimaryButton(
                                  onPressed: _loading ? null : _signInWithGoogle,
                                  label: _loading
                                      ? tr('Signing in...', 'লগইন হচ্ছে...')
                                      : tr(
                                          'Continue with Google',
                                          'Google দিয়ে প্রবেশ করুন',
                                        ),
                                  icon: Icons.g_mobiledata_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Info tiles
                    Row(
                      children: [
                        Expanded(
                          child: _LoginInfoTile(
                            icon: Icons.lock_outline_rounded,
                            text: tr('Secure', 'নিরাপদ'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LoginInfoTile(
                            icon: Icons.shield_outlined,
                            text: tr('Private', 'ব্যক্তিগত'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LoginInfoTile(
                            icon: Icons.flash_on_rounded,
                            text: tr('Instant', 'তাৎক্ষণিক'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final isNew = await DataService.instance.signInWithGoogle();
      if (!mounted) return;
      if (isNew || !(await DataService.instance.isProfileComplete())) {
        // New user or incomplete profile → show profile setup.
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      final message = _googleSignInErrorMessage(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _googleSignInErrorMessage(Object error) {
    if (error is PlatformException) {
      final raw = '${error.code} ${error.message ?? ''} ${error.details ?? ''}';
      final normalized = raw.toLowerCase();
      final isConfigError =
          normalized.contains('sign_in_failed') &&
          (normalized.contains('api: 10') ||
              normalized.contains('api:10') ||
              normalized.contains('developer_error') ||
              normalized.contains('common.api.j: 10') ||
              normalized.contains('common.api.j:10'));
      if (isConfigError) {
        return tr(
          'Google login is not configured for this app build yet. Please contact support/admin to add Android SHA keys in Firebase and update google-services.json.',
          'এই অ্যাপ বিল্ডের জন্য Google লগইন এখনো কনফিগার করা হয়নি। Firebase-এ Android SHA key যোগ করে google-services.json আপডেট করতে অ্যাডমিন/সাপোর্টের সাথে যোগাযোগ করুন।',
        );
      }
    }
    return '${tr('Error', 'ত্রুটি')}: $error';
  }
}

class _LoginInfoTile extends StatelessWidget {
  const _LoginInfoTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderC(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryC(context), size: 22),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondaryC(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Setup Screen ───────────────────────────────────────────────────

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.existingProfile});
  final Map<String, dynamic>? existingProfile;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  final _phoneCtrl = TextEditingController();
  String? _profession;
  String? _village;
  final _addressCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _bloodGroup;
  bool _saving = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  static const _villages = ['দৌলতপাড়া', 'ধর্মতীর্থ', 'দিঘীরপাড়া'];

  static final _professions = [
    tr('Expatriate', 'প্রবাসী'),
    tr('Farmer', 'কৃষক'),
    tr('Teacher', 'শিক্ষক'),
    tr('Student', 'ছাত্র/ছাত্রী'),
    tr('Doctor', 'ডাক্তার'),
    tr('Engineer', 'ইঞ্জিনিয়ার'),
    tr('Businessman', 'ব্যবসায়ী'),
    tr('Housewife', 'গৃহিণী'),
    tr('Government Employee', 'সরকারি চাকরিজীবী'),
    tr('Private Employee', 'বেসরকারি চাকরিজীবী'),
    tr('Day Laborer', 'দিনমজুর'),
    tr('Fisherman', 'জেলে'),
    tr('Driver', 'চালক'),
    tr('Tailor', 'দর্জি'),
    tr('Imam/Religious Leader', 'ইমাম/ধর্মীয় নেতা'),
    tr('Retired', 'অবসরপ্রাপ্ত'),
    tr('Unemployed', 'বেকার'),
    tr('Other', 'অন্যান্য'),
  ];

  @override
  void initState() {
    super.initState();
    final user = DataService.instance.currentUser;
    final profile = widget.existingProfile;
    _nameCtrl = TextEditingController(
      text: profile?['name'] as String? ?? user?.displayName ?? '',
    );
    _phoneCtrl.text = profile?['phone'] as String? ?? '';
    _addressCtrl.text = profile?['address'] as String? ?? '';
    _nidCtrl.text = profile?['nidNumber'] as String? ?? '';
    _dobCtrl.text = profile?['dateOfBirth'] as String? ?? '';

    // Pre-fill village.
    final savedVillage = profile?['village'] as String? ?? '';
    if (savedVillage.isNotEmpty && _villages.contains(savedVillage)) {
      _village = savedVillage;
    }

    // Pre-fill profession if it matches one of the options.
    final savedProfession = profile?['profession'] as String? ?? '';
    if (savedProfession.isNotEmpty && _professions.contains(savedProfession)) {
      _profession = savedProfession;
    }

    // Pre-fill blood group.
    final savedBlood = profile?['bloodGroup'] as String? ?? '';
    if (savedBlood.isNotEmpty && _bloodGroups.contains(savedBlood)) {
      _bloodGroup = savedBlood;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _nidCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = DataService.instance.currentUser;
    final pad = _pagePadding(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _pageBackdrop(
        safeArea: true,
        child: FadeTransition(
          opacity: _fadeIn,
          child: _constrainBodyWidth(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pad.left, 16, pad.right, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryC(context).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primaryC(context).withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child:
                                user?.photoURL != null &&
                                    user!.photoURL!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.network(
                                      user.photoURL!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primaryC(context),
                                    size: 40,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.existingProfile != null
                                ? tr(
                                    'Edit Your Profile',
                                    'প্রোফাইল সম্পাদনা করুন',
                                  )
                                : tr(
                                    'Setup Your Profile',
                                    'প্রোফাইল সেটআপ করুন',
                                  ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryC(context),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr(
                              'Complete your profile to join the village community',
                              'গ্রাম কমিউনিটিতে যোগ দিতে আপনার প্রোফাইল সম্পূর্ণ করুন',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryC(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name
                    _buildLabel(tr('Full Name', 'পুরো নাম'), required: true),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: tr('Enter your full name', 'আপনার পুরো নাম লিখুন'),
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? tr('Name is required', 'নাম আবশ্যক')
                          : null,
                    ),
                    const SizedBox(height: 18),

                    // Phone
                    _buildLabel(
                      tr('Phone Number', 'ফোন নম্বর'),
                      required: true,
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _phoneCtrl,
                      hint: tr('01XXXXXXXXX', '০১XXXXXXXXX'),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return tr(
                            'Phone number is required',
                            'ফোন নম্বর আবশ্যক',
                          );
                        }
                        if (v.trim().length < 11) {
                          return tr(
                            'Enter a valid phone number',
                            'সঠিক ফোন নম্বর লিখুন',
                          );
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Profession
                    _buildLabel(tr('Profession', 'পেশা'), required: true),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderC(context)),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _profession,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.work_outline_rounded,
                            color: AppColors.textSecondaryC(context),
                            size: 20,
                          ),
                          hintText: tr(
                            'Select profession',
                            'পেশা নির্বাচন করুন',
                          ),
                          hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        isExpanded: true,
                        items: _professions
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        validator: (v) => (v == null || v.isEmpty)
                            ? tr('Profession is required', 'পেশা আবশ্যক')
                            : null,
                        onChanged: (v) => setState(() => _profession = v),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Village
                    _buildLabel(tr('Village', 'গ্রাম'), required: true),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderC(context)),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _village,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.home_outlined,
                            color: AppColors.textSecondaryC(context),
                            size: 20,
                          ),
                          hintText: tr('Select village', 'গ্রাম নির্বাচন করুন'),
                          hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        isExpanded: true,
                        items: _villages
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        validator: (v) => (v == null || v.isEmpty)
                            ? tr('Village is required', 'গ্রাম নির্বাচন আবশ্যক')
                            : null,
                        onChanged: (v) => setState(() => _village = v),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Address
                    _buildLabel(tr('Address', 'ঠিকানা')),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _addressCtrl,
                      hint: tr(
                        'Area / Para (optional)',
                        'এলাকা / পাড়া (ঐচ্ছিক)',
                      ),
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 18),

                    // Blood Group
                    _buildLabel(tr('Blood Group', 'রক্তের গ্রুপ')),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderC(context)),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _bloodGroup,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.bloodtype_outlined,
                            color: AppColors.textSecondaryC(context),
                            size: 20,
                          ),
                          hintText: tr(
                            'Select blood group',
                            'রক্তের গ্রুপ নির্বাচন করুন',
                          ),
                          hintStyle: const TextStyle(
                            color: Color(0xFFC7C7CC),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        items: _bloodGroups
                            .map(
                              (bg) =>
                                  DropdownMenuItem(value: bg, child: Text(bg)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _bloodGroup = v),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // NID Number
                    _buildLabel(tr('NID Number', 'জাতীয় পরিচয়পত্র নম্বর')),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nidCtrl,
                      hint: tr('Optional', 'ঐচ্ছিক'),
                      icon: Icons.credit_card_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),

                    // Date of Birth
                    _buildLabel(tr('Date of Birth', 'জন্ম তারিখ')),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _dobCtrl,
                          hint: tr('Select date', 'তারিখ নির্বাচন করুন'),
                          icon: Icons.cake_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    PrimaryButton(
                      isLoading: _saving,
                      onPressed: _saving ? null : _saveProfile,
                      label: widget.existingProfile != null
                          ? tr(
                              'Update Profile',
                              'প্রোফাইল আপডেট করুন',
                            )
                          : tr(
                              'Save & Continue',
                              'সংরক্ষণ করুন ও এগিয়ে যান',
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Skip button
                    Center(
                      child: TextButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          tr(
                            widget.existingProfile != null
                                ? 'Cancel'
                                : 'Skip for now',
                            widget.existingProfile != null
                                ? 'বাতিল'
                                : 'এখন এড়িয়ে যান',
                          ),
                          style: TextStyle(
                            color: AppColors.textSecondaryC(context),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimaryC(context),
          ),
        ),
        if (required)
          Text(
            ' *',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.errorC(context)),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return PremiumTextField(
      controller: controller,
      labelText: null,
      hintText: hint,
      prefixIcon: icon,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryC(context),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await DataService.instance.updateUserProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        profession: _profession ?? '',
        village: _village ?? '',
        address: _addressCtrl.text.trim(),
        nidNumber: _nidCtrl.text.trim(),
        bloodGroup: _bloodGroup,
        dateOfBirth: _dobCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Profile saved successfully!',
              'প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে!',
            ),
          ),
          backgroundColor: AppColors.successC(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('Error', 'ত্রুটি')}: $e'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _link = TextEditingController();
  bool _loading = false;
  bool _linkSent = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _email.dispose();
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A5F), Color(0xFF0F1B2D)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: size.width > 400 ? 32 : 24),
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
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    // Glowing village icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, 8)),
                          BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.2), blurRadius: 64, spreadRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 38),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      tr('Welcome Back', 'স্বাগতম'),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('Sign in to your village community', 'আপনার গ্রাম কমিউনিটিতে সাইন ইন করুন'),
                      style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: size.height * 0.04),
                    // Step indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepDot(step: 1, label: tr('Email', 'ইমেইল'), active: true, done: _linkSent),
                        Container(
                          width: 40,
                          height: 2,
                          color: _linkSent ? const Color(0xFF3B82F6) : Colors.white.withValues(alpha: 0.15),
                        ),
                        _StepDot(step: 2, label: tr('Verify', 'যাচাই'), active: _linkSent, done: false),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Main card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('Email Address', 'ইমেইল ঠিকানা'),
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'you@example.com',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.4), size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Send OTP button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _loading ? null : _sendLink,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: _loading && !_linkSent
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(
                                            _linkSent ? tr('Resend OTP Link', 'আবার OTP লিংক পাঠান') : tr('Send OTP Link', 'OTP লিংক পাঠান'),
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          // Verification section
                          AnimatedSize(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            child: _linkSent
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 24),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF059669).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.25)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 20),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                tr('OTP link sent! Check your inbox.', 'OTP লিংক পাঠানো হয়েছে! ইনবক্স দেখুন।'),
                                                style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 13, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        tr('Paste Verification Link', 'ভেরিফিকেশন লিংক পেস্ট করুন'),
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                        ),
                                        child: TextField(
                                          controller: _link,
                                          minLines: 2,
                                          maxLines: 4,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          decoration: InputDecoration(
                                            hintText: tr('Paste the link from your email...', 'আপনার ইমেইল থেকে লিংক পেস্ট করুন...'),
                                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(bottom: 24),
                                              child: Icon(Icons.link_rounded, color: Colors.white.withValues(alpha: 0.4), size: 20),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF047857)]),
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(color: const Color(0xFF059669).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: _loading ? null : _verify,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            ),
                                            child: _loading
                                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.verified_rounded, size: 18, color: Colors.white),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        tr('Verify & Login', 'যাচাই করে লগইন'),
                                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info tiles
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.lock_outline_rounded,
                            text: tr('Passwordless', 'পাসওয়ার্ড ছাড়া'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.shield_outlined,
                            text: tr('Secure Login', 'নিরাপদ লগইন'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
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
    );
  }

  Future<void> _sendLink() async {
    if (!_email.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('Enter a valid email address', 'সঠিক ইমেইল ঠিকানা দিন')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      await DataService.instance.sendLoginLink(_email.text.trim());
      if (!mounted) return;
      setState(() {
        _linkSent = true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${tr('Error', 'ত্রুটি')}: $e'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    try {
      await DataService.instance.signInWithEmailLink(email: _email.text.trim(), emailLink: _link.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${tr('Error', 'ত্রুটি')}: $e'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.step, required this.label, required this.active, required this.done});
  final int step;
  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? const Color(0xFF059669)
                : active
                    ? const Color(0xFF3B82F6)
                    : Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: done
                  ? const Color(0xFF059669)
                  : active
                      ? const Color(0xFF3B82F6)
                      : Colors.white.withValues(alpha: 0.15),
              width: 2,
            ),
            boxShadow: active || done
                ? [BoxShadow(color: (done ? const Color(0xFF059669) : const Color(0xFF3B82F6)).withValues(alpha: 0.3), blurRadius: 12)]
                : [],
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text('$step', style: TextStyle(color: active ? Colors.white : Colors.white.withValues(alpha: 0.35), fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: active || done ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF60A5FA), size: 22),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
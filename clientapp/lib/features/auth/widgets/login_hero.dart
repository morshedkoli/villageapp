// Decorative gradient hero occupying the top of the login screen.


import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/motion.dart';

class HeroBackground extends StatelessWidget {
  final double height;
  final bool isDark;
  const HeroBackground({super.key, required this.height, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkCanvas,
                    AppColors.primaryDark,
                    AppColors.primary,
                  ]
                : [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

class GeometricDecoration extends StatelessWidget {
  final double height;
  const GeometricDecoration({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _CirclePatternPainter()),
    );
  }
}

class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Large arc top-right
    canvas.drawCircle(Offset(size.width + 20, -30), 180, paint);
    canvas.drawCircle(Offset(size.width + 20, -30), 130, paint);

    // Small circles bottom-left
    final fill = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-40, size.height * 0.7), 120, fill);
    canvas.drawCircle(Offset(-40, size.height * 0.7), 80, paint);

    // Dotted grid pattern
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    const spacing = 32.0;
    for (double x = spacing; x < size.width - 40; x += spacing) {
      for (double y = spacing; y < size.height * 0.6; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class HeroContent extends StatelessWidget {
  final Animation<double> pulseAnim;
  final Animation<double> heroAnim;

  const HeroContent({super.key, 
    required this.pulseAnim,
    required this.heroAnim,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing glow ring + icon
            FadeTransition(
              opacity: heroAnim,
              child: AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: pulseAnim.value,
                  child: child,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Inner icon container
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.holiday_village_rounded,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.hXxl,

            // App title
            FadeSlideIn(
              delay: 150,
              child: Text(
                'আল ইসলাহ',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.hSm,

            // Subtitle
            FadeSlideIn(
              delay: 230,
              child: Text(
                'গ্রামের ডিজিটাল কমিউনিটি প্ল্যাটফর্ম',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.hXxl,

            // Feature pills
            FadeSlideIn(
              delay: 320,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: const [
                  _PillChip(icon: Icons.volunteer_activism_rounded, label: 'তহবিল'),
                  _PillChip(icon: Icons.construction_rounded, label: 'প্রকল্প'),
                  _PillChip(icon: Icons.people_rounded, label: 'নাগরিক'),
                  _PillChip(icon: Icons.campaign_rounded, label: 'নোটিশ'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PillChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          AppSpacing.wXs,
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

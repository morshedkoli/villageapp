import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/category_icon_badge.dart';
import '../onboarding_pages.dart';

/// One introductory feature slide: badge, headline and supporting copy.
class FeaturePageView extends StatelessWidget {
  const FeaturePageView({super.key, required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          CategoryIconBadge(icon: page.icon, color: page.color, size: 132),
          const SizedBox(height: 40),
          Text(
            page.titleBn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.descBn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: context.textSecondary,
              height: 1.55,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

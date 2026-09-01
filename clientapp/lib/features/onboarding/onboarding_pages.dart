import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Preference flag recording that onboarding has been seen.
///
/// Read by the splash screen to decide whether to route to onboarding or
/// straight to login; both sides used to spell the key out by hand.
const String kOnboardingCompleteKey = 'onboarding_complete';

/// One of the introductory feature slides.
class OnboardingPage {
  const OnboardingPage({
    required this.icon,
    required this.titleBn,
    required this.descBn,
    required this.color,
  });

  final IconData icon;
  final String titleBn;
  final String descBn;
  final Color color;
}

const List<OnboardingPage> kFeaturePages = [
  OnboardingPage(
    icon: Icons.account_balance_wallet_rounded,
    titleBn: 'স্বচ্ছ গ্রাম তহবিল',
    descBn:
        'প্রতিটি অনুদান ও খরচ রিয়েল-টাইমে ট্র্যাক করুন। গ্রামের তহবিল কিভাবে ব্যবহার হচ্ছে তা দেখুন।',
    color: AppColors.primary,
  ),
  OnboardingPage(
    icon: Icons.construction_rounded,
    titleBn: 'উন্নয়ন প্রকল্প',
    descBn:
        'গ্রাম উন্নয়ন প্রকল্প, তাদের অগ্রগতি এবং খরচের রিপোর্ট পর্যবেক্ষণ করুন।',
    color: AppColors.accentGold,
  ),
  OnboardingPage(
    icon: Icons.report_problem_rounded,
    titleBn: 'সমস্যা রিপোর্ট',
    descBn:
        'ছবি ও অবস্থান সহ গ্রামের সমস্যা রিপোর্ট করুন। সমাধানের অগ্রগতি ট্র্যাক করুন।',
    color: AppColors.accentTerracotta,
  ),
  OnboardingPage(
    icon: Icons.people_rounded,
    titleBn: 'জনগণের অংশগ্রহণ',
    descBn:
        'আপনার গ্রামের কমিউনিটিতে যোগ দিন। অনুদান দিন, অংশগ্রহণ করুন এবং একসাথে পরিবর্তন আনুন।',
    color: AppColors.info,
  ),
];

/// Feature slides plus the trailing notification-permission slide.
///
/// Derived rather than written out, so adding a feature page cannot leave the
/// progress bar and page count disagreeing with what the PageView builds.
final int kOnboardingPageCount = kFeaturePages.length + 1;

/// Whether [index] is the final slide, which asks for notification permission.
bool isNotificationPage(int index) => index >= kFeaturePages.length;

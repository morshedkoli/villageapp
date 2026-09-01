import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Brand colour for a payment account type, as written by the admin panel.
Color providerColor(String type) {
  switch (type.toLowerCase()) {
    case 'bkash':
      return const Color(0xFFE2136E);
    case 'nagad':
      return const Color(0xFFFF6B00);
    case 'dutch-bangla':
    case 'dbbl':
      return const Color(0xFF00A859);
    case 'rocket':
      return const Color(0xFF8B008B);
    default:
      return AppColors.primary;
  }
}

IconData providerIcon(String type) {
  switch (type.toLowerCase()) {
    case 'bank':
      return Icons.account_balance_rounded;
    default:
      return Icons.phone_android_rounded;
  }
}

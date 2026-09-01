// Page title and subtitle for the donation overview.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

class DonationHeader extends StatelessWidget {
  const DonationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'দান ও তহবিল',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.hXs,
            Text(
              'আপনার দানেই সমৃদ্ধ আমাদের গ্রাম',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(Icons.volunteer_activism_outlined, size: 22, color: context.primary),
        ),
      ],
    );
  }
}

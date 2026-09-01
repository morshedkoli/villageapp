// Donation category chips.
//
// NOTE: these chips are presentational only. The selection is tracked and
// highlighted, but nothing downstream filters on it — `Donation` carries no
// category field, so the data to filter by does not exist yet. Tapping a
// category changes the highlight and nothing else.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

class CategoryFilters extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryFilters({super.key, 
    required this.selectedCategory,
    required this.onSelected,
  });

  static const _categories = [
    'সব', 
    'জরুরি তহবিল', 
    'মসজিদ', 
    'শিক্ষা', 
    'স্বাস্থ্য', 
    'রাস্তা মেরামত'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'বিভাগ',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.hMd,
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => AppSpacing.wSm,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final selected = selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (val) {
                  if (val) onSelected(cat);
                },
                labelStyle: context.textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.primary : context.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundColor: context.isDark ? AppColors.darkCard : AppColors.lightCanvas,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// A rounded, tinted-circle icon used to mark a category (donation, problem,
/// project, notification, ...). Rotate [color] through
/// `AppColors.primary` / `accentTerracotta` / `accentGold` / `info` by
/// category for visual variety — see call sites for the convention.
class CategoryIconBadge extends StatelessWidget {
  const CategoryIconBadge({
    required this.icon,
    required this.color,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

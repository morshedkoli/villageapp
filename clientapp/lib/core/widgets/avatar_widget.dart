import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ──────────────────────────────────────────────
///  AvatarWidget — user / citizen avatar
///  Improvements:
///  • Multi-word initial extraction (first letter of each word)
///  • Token-driven gradient (primary → primaryDark)
///  • Online indicator uses token colors
/// ──────────────────────────────────────────────
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  final bool showOnline;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = 48,
    this.showOnline = false,
    this.backgroundColor,
  });

  /// Extract up to 2 initials from a name, one from each word.
  static String extractInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words[words.length > 1 ? 1 : 0][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: (imageUrl != null && imageUrl!.isNotEmpty)
                ? Image.network(
                    imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _Placeholder(
                      initials: initials,
                      size: size,
                      bg: backgroundColor,
                    ),
                  )
                : _Placeholder(initials: initials, size: size, bg: backgroundColor),
          ),
          if (showOnline)
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: size * 0.27,
                height: size * 0.27,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String initials;
  final double size;
  final Color? bg;
  const _Placeholder({required this.initials, required this.size, this.bg});

  @override
  Widget build(BuildContext context) {
    final extracted = AvatarWidget.extractInitials(initials);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: bg == null
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: bg,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          extracted,
          style: TextStyle(
            color: AppColors.inkOnPrimary,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

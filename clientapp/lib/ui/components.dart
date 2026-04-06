import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models.dart';
import 'design_system.dart';

final NumberFormat currency = NumberFormat.currency(
  locale: 'bn_BD',
  symbol: '৳',
);
final DateFormat shortDate = DateFormat('dd MMM yyyy');

// ============================================================================
// APP CARD - Premium card with soft shadows
// ============================================================================

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final compactLayout = MediaQuery.of(context).size.width <= 360;
    final resolvedPadding =
        padding ?? EdgeInsets.all(compactLayout ? 16 : 20);

    final card = AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: elevated ? AppShadows.elevated : AppShadows.soft,
      ),
      child: Padding(padding: resolvedPadding, child: child),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: card,
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE - Color-coded status indicator
// ============================================================================

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final normalized = text.toLowerCase();
    final Color color;
    final Color bg;
    if (normalized.contains('completed') || normalized.contains('approved')) {
      color = AppColors.success;
      bg = AppColors.success.withValues(alpha: 0.1);
    } else if (normalized.contains('progress')) {
      color = AppColors.warning;
      bg = AppColors.warning.withValues(alpha: 0.1);
    } else if (normalized.contains('urgent') ||
        normalized.contains('pending')) {
      color = AppColors.error;
      bg = AppColors.error.withValues(alpha: 0.1);
    } else if (normalized.contains('planning')) {
      color = AppColors.secondary;
      bg = AppColors.secondary.withValues(alpha: 0.1);
    } else if (normalized.contains('rejected')) {
      color = AppColors.error;
      bg = AppColors.error.withValues(alpha: 0.1);
    } else {
      color = AppColors.textSecondary;
      bg = AppColors.surfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ============================================================================
// PROJECT CARD - Development project display
// ============================================================================

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.item,
    this.onTap,
    this.compact = false,
  });

  final DevelopmentProject item;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final progress = item.estimatedCost <= 0
        ? 0.0
        : (item.allocatedFunds / item.estimatedCost).clamp(0.0, 1.0);

    return SizedBox(
      width: compact ? 280 : null,
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(text: item.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _fundLabel('Allocated', currency.format(item.allocatedFunds)),
                const SizedBox(width: 16),
                _fundLabel('Estimated', currency.format(item.estimatedCost)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: SizedBox(
                      height: 6,
                      child: Stack(
                        children: [
                          Container(color: AppColors.surfaceVariant),
                          AnimatedFractionallySizedBox(
                            duration: AppDurations.slow,
                            curve: AppCurves.standard,
                            widthFactor: progress,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.primaryGradient,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fundLabel(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ============================================================================
// PROBLEM CARD - Community issue display
// ============================================================================

class ProblemCard extends StatelessWidget {
  const ProblemCard({
    super.key,
    required this.item,
    this.compact = false,
    this.voteBar,
  });

  final ProblemReport item;
  final bool compact;
  final Widget? voteBar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 320 : null,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.photoUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.photoUrl,
                  width: double.infinity,
                  height: compact ? 120 : 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusBadge(text: item.status),
              ],
            ),
            const SizedBox(height: 6),
            Text('Location: ${item.location}'),
            const SizedBox(height: 6),
            Text(
              item.description,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (voteBar != null) ...[
              const SizedBox(height: 12),
              voteBar!,
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DONATION CARD - Donation display
// ============================================================================

class DonationCard extends StatelessWidget {
  const DonationCard({super.key, required this.item, this.compact = false, this.showStatus = false});

  final Donation item;
  final bool compact;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.colorGlow(AppColors.primary, 0.2),
              ),
              child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.donorName,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.paymentMethod} · ${shortDate.format(item.createdAt)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(item.amount),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success, fontSize: 15),
                ),
                if (showStatus && item.status != 'Approved')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: StatusBadge(text: item.status),
                  ),
              ],
            ),
          ],
        ),
      ],
    );

    if (compact) {
      return SizedBox(width: 310, child: AppCard(child: content));
    }

    return AppCard(child: content);
  }
}

// ============================================================================
// EMPTY STATE CARD - Friendly empty state display
// ============================================================================

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.primaryGlow(0.2),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ============================================================================
// PRIMARY BUTTON - Gradient button with press animation
// ============================================================================

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.gradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final List<Color>? gradient;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradient ?? AppColors.primaryGradient;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled ? null : (_) => _controller.reverse(),
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedOpacity(
          duration: AppDurations.fast,
          opacity: isDisabled ? 0.6 : 1.0,
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            height: AppButtonSizes.large,
            padding: widget.fullWidth ? null : const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.colorGlow(colors[0], 0.3),
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECONDARY BUTTON - Outlined button
// ============================================================================

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonColor,
        side: BorderSide(color: buttonColor.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        minimumSize: const Size.fromHeight(AppButtonSizes.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 10),
          ],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}

// ============================================================================
// STAT CARD - Premium stat display with gradient icon
// ============================================================================

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.trendPositive = true,
    this.gradient,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final bool trendPositive;
  final List<Color>? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? AppColors.primaryGradient;

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.colorGlow(colors[0], 0.3),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              if (trend != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trendPositive ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositive ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: trendPositive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trendPositive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}

// ============================================================================
// SHIMMER LOADING - Animated shimmer effect
// ============================================================================

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmer,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? widget.height / 2,
            ),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                AppColors.border,
                AppColors.surfaceVariant,
                AppColors.border,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// CARD SKELETON - Skeleton loading for cards
// ============================================================================

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading(width: 44, height: 44, borderRadius: AppRadius.md),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLoading(width: 120, height: 14),
                    SizedBox(height: 8),
                    ShimmerLoading(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const ShimmerLoading(height: 12),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 200, height: 12),
        ],
      ),
    );
  }
}

// ============================================================================
// LIST SKELETON - Multiple skeleton cards
// ============================================================================

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.itemCount = 3, this.itemHeight = 100});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CardSkeleton(height: itemHeight),
        ),
      ),
    );
  }
}

// ============================================================================
// TAP SCALE - Reusable scale-on-tap wrapper
// ============================================================================

class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.96,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.scale(
          scale: _animation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// ANIMATED VOTE BAR - Progress bar for voting
// ============================================================================

class AnimatedVoteBar extends StatelessWidget {
  const AnimatedVoteBar({
    super.key,
    required this.upvotes,
    required this.downvotes,
  });

  final int upvotes;
  final int downvotes;

  @override
  Widget build(BuildContext context) {
    final total = upvotes + downvotes;
    final upPercent = total > 0 ? upvotes / total : 0.5;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.error.withValues(alpha: 0.15),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: AppDurations.slow,
                curve: AppCurves.standard,
                width: constraints.maxWidth * upPercent,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(colors: AppColors.successGradient),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class VoteBar extends StatelessWidget {
  const VoteBar({
    super.key,
    required this.upvotes,
    required this.downvotes,
  });

  final int upvotes;
  final int downvotes;

  @override
  Widget build(BuildContext context) {
    return AnimatedVoteBar(upvotes: upvotes, downvotes: downvotes);
  }
}

// ============================================================================
// SLIDE UP PAGE ROUTE - Custom page transition
// ============================================================================

class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
      : super(
          transitionDuration: AppDurations.pageTransition,
          reverseTransitionDuration: AppDurations.normal,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: AppCurves.standard,
            ));

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
        );
}

// ============================================================================
// ICON CONTAINER - Consistent icon container styling
// ============================================================================

class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 22,
    this.gradient,
    this.color,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final List<Color>? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? AppColors.primaryGradient;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: color == null ? LinearGradient(colors: colors) : null,
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: color == null ? AppShadows.colorGlow(colors[0], 0.25) : null,
      ),
      child: Icon(
        icon,
        color: color == null ? Colors.white : AppColors.primary,
        size: iconSize,
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER - Section title with optional action
// ============================================================================

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

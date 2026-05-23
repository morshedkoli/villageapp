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

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevated = false,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? backgroundColor;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final compactLayout = MediaQuery.of(context).size.width <= 360;
    final resolvedPadding =
        widget.padding ?? EdgeInsets.all(compactLayout ? 14 : 18);

    final card = AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surfaceC(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: AppColors.borderC(context),
          width: 1,
        ),
        boxShadow: widget.elevated ? AppShadows.soft : AppShadows.none,
      ),
      child: Padding(padding: resolvedPadding, child: widget.child),
    );

    if (widget.onTap == null) {
      return card;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onHighlightChanged: (isHighlighted) {
            if (!isHighlighted) {
              setState(() => _isPressed = false);
            }
          },
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          splashColor: AppColors.primaryC(context).withValues(alpha: 0.05),
          highlightColor: AppColors.primaryC(context).withValues(alpha: 0.03),
          child: card,
        ),
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
      color = AppColors.successC(context);
      bg = AppColors.successC(context).withValues(alpha: 0.1);
    } else if (normalized.contains('progress')) {
      color = AppColors.warningC(context);
      bg = AppColors.warningC(context).withValues(alpha: 0.1);
    } else if (normalized.contains('urgent') ||
        normalized.contains('pending')) {
      color = AppColors.errorC(context);
      bg = AppColors.errorC(context).withValues(alpha: 0.1);
    } else if (normalized.contains('planning')) {
      color = AppColors.secondary;
      bg = AppColors.secondary.withValues(alpha: 0.1);
    } else if (normalized.contains('rejected')) {
      color = AppColors.errorC(context);
      bg = AppColors.errorC(context).withValues(alpha: 0.1);
    } else {
      color = AppColors.textSecondaryC(context);
      bg = AppColors.surfaceVariantC(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.1,
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

  Color _statusColor(BuildContext context) {
    switch (item.status.toLowerCase()) {
      case 'completed':
        return AppColors.successC(context);
      case 'in progress':
        return AppColors.infoC(context);
      case 'planning':
        return AppColors.secondary;
      case 'urgent':
        return AppColors.errorC(context);
      default:
        return AppColors.warningC(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = item.estimatedCost <= 0
        ? 0.0
        : (item.allocatedFunds / item.estimatedCost).clamp(0.0, 1.0);
    final statusColor = _statusColor(context);

    if (compact) return _buildCompactCard(context, progress, statusColor);
    return _buildFullCard(context, progress, statusColor);
  }

  Widget _buildCompactCard(BuildContext context, double progress, Color statusColor) {
    return SizedBox(
      width: 270,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top gradient banner
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor.withValues(alpha: 0.18), statusColor.withValues(alpha: 0.06)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Hero(
                  tag: 'project-icon-${item.id}',
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(Icons.construction_rounded, color: statusColor.withValues(alpha: 0.3), size: 50),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: StatusBadge(text: item.status),
                      ),
                      // progress bar at bottom of banner
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          child: SizedBox(
                            height: 4,
                            child: Stack(
                              children: [
                                Container(color: statusColor.withValues(alpha: 0.1)),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [statusColor, statusColor.withValues(alpha: 0.7)]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryC(context),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                     style: TextStyle(fontSize: 12, color: AppColors.textTertiaryC(context), height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currency.format(item.allocatedFunds),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: statusColor)),
                             Text('allocated', style: TextStyle(fontSize: 10, color: AppColors.textTertiaryC(context))),
                          ],
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: statusColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, double progress, Color statusColor) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'project-icon-${item.id}',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [statusColor, statusColor.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: AppShadows.colorGlow(statusColor, 0.25),
                  ),
                   child: const Icon(Icons.construction_rounded, color: AppColors.onGradient, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryC(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(text: item.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
             style: TextStyle(color: AppColors.textSecondaryC(context), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _fundLabel(context, 'Allocated', currency.format(item.allocatedFunds), statusColor),
              const SizedBox(width: 16),
               _fundLabel(context, 'Estimated', currency.format(item.estimatedCost), AppColors.textTertiaryC(context)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: SizedBox(
                    height: 8,
                    child: Stack(
                      children: [
                         Container(color: AppColors.surfaceVariantC(context)),
                        AnimatedFractionallySizedBox(
                          duration: AppDurations.slow,
                          curve: AppCurves.standard,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (onTap != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: statusColor),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fundLabel(BuildContext context, String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondaryC(context), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor)),
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
    this.onTap,
  });

  final ProblemReport item;
  final bool compact;
  final Widget? voteBar;
  final VoidCallback? onTap;

  Color _statusColor(BuildContext context) {
    switch (item.status.toLowerCase()) {
      case 'approved':
        return AppColors.successC(context);
      case 'completed':
        return AppColors.infoC(context);
      case 'pending':
        return AppColors.warningC(context);
      default:
        return AppColors.textSecondaryC(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompactCard(context);
    return _buildFullCard(context);
  }

  Widget _buildCompactCard(BuildContext context) {
    final statusColor = _statusColor(context);
    return SizedBox(
      width: 300,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or gradient banner
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
              child: Hero(
                tag: 'problem-image-${item.id}',
                child: item.photoUrl.isNotEmpty
                    ? Image.network(
                        item.photoUrl,
                        width: double.infinity,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _gradientBanner(statusColor),
                      )
                    : _gradientBanner(statusColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryC(context),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(text: item.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryC(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                       fontSize: 12,
                       color: AppColors.textTertiaryC(context),
                       height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_rounded, size: 12, color: AppColors.successC(context)),
                      const SizedBox(width: 3),
                      Text('${item.upvotes}', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryC(context), fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Icon(Icons.thumb_down_rounded, size: 12, color: AppColors.errorC(context)),
                      const SizedBox(width: 3),
                      Text('${item.downvotes}', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryC(context), fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: statusColor.withValues(alpha: 0.7)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientBanner(Color color) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_amber_rounded, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    final statusColor = _statusColor(context);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.photoUrl.isNotEmpty) ...[
            Hero(
              tag: 'problem-image-${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  item.photoUrl,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'problem-image-${item.id}',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.warning_amber_rounded, color: statusColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryC(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 12, color: AppColors.textTertiaryC(context)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryC(context)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(text: item.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryC(context), height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textTertiaryC(context)),
              const SizedBox(width: 4),
              Text(
                item.reportedBy,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiaryC(context)),
              ),
              const Spacer(),
              if (onTap != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded, size: 12, color: statusColor),
                    ],
                  ),
                ),
            ],
          ),
          if (voteBar != null) ...[
            const SizedBox(height: 12),
            voteBar!,
          ],
        ],
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.successC(context).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.volunteer_activism_rounded,
                color: AppColors.successC(context),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.donorName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimaryC(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.paymentMethod} · ${shortDate.format(item.createdAt)}',
                    style: TextStyle(
                      color: AppColors.textTertiaryC(context),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(item.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryC(context),
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
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
      return SizedBox(width: 280, child: AppCard(child: content));
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
    this.actionLabel,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryC(context).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primaryC(context), size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryC(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textTertiaryC(context),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (actionLabel != null && action != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: action,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryC(context),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
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
    final accent = colors.first;
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
          opacity: isDisabled ? 0.55 : 1.0,
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            height: AppButtonSizes.large,
            padding: widget.fullWidth
                ? null
                : const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
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
    final buttonColor = color ?? AppColors.textPrimaryC(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonColor,
        backgroundColor: AppColors.surfaceC(context),
        side: BorderSide(color: AppColors.borderC(context), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        minimumSize: const Size.fromHeight(AppButtonSizes.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
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
    final accent = colors.first;

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceC(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.borderC(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              if (trend != null) ...[
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: trendPositive
                          ? AppColors.successC(context)
                          : AppColors.errorC(context),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: trendPositive
                            ? AppColors.successC(context)
                            : AppColors.errorC(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryC(context),
              letterSpacing: -0.3,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiaryC(context),
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
              colors: [
                AppColors.borderC(context),
                AppColors.surfaceVariantC(context),
                AppColors.borderC(context),
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
        color: AppColors.surfaceC(context),
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
// STATS SKELETON - Grid of stat cards skeleton
// ============================================================================

class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key, this.columns = 2, this.rows = 2});

  final int columns;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rows,
        (row) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: List.generate(
              columns,
              (col) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: col == 0 ? 0 : 6,
                    right: col == columns - 1 ? 0 : 6,
                  ),
                  child: Container(
                    height: 90,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceC(context),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: AppShadows.soft,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerLoading(width: 36, height: 36, borderRadius: 10),
                        ShimmerLoading(width: 60, height: 20),
                        ShimmerLoading(width: 80, height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FUND SKELETON - Village fund page skeleton
// ============================================================================

class FundSkeleton extends StatelessWidget {
  const FundSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            height: 140,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceC(context),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.soft,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLoading(width: 100, height: 14),
                ShimmerLoading(width: 160, height: 32),
                Row(
                  children: [
                    ShimmerLoading(width: 80, height: 12),
                    SizedBox(width: 20),
                    ShimmerLoading(width: 80, height: 12),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerLoading(width: 140, height: 18),
          const SizedBox(height: 16),
          const ListSkeleton(itemCount: 3, itemHeight: 80),
        ],
      ),
    );
  }
}

// ============================================================================
// LEADERBOARD SKELETON - Leaderboard page skeleton
// ============================================================================

class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top 3 podium
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumSkeleton(70),
              const SizedBox(width: 12),
              _buildPodiumSkeleton(90),
              const SizedBox(width: 12),
              _buildPodiumSkeleton(60),
            ],
          ),
          const SizedBox(height: 24),
          // Rest of list
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceC(context),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.soft,
                ),
                child: const Row(
                  children: [
                    ShimmerLoading(width: 24, height: 20),
                    SizedBox(width: 12),
                    ShimmerLoading(width: 44, height: 44, borderRadius: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoading(width: 100, height: 14),
                          SizedBox(height: 6),
                          ShimmerLoading(width: 60, height: 12),
                        ],
                      ),
                    ),
                    ShimmerLoading(width: 50, height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSkeleton(double height) {
    return Column(
      children: [
        const ShimmerLoading(width: 56, height: 56, borderRadius: 28),
        const SizedBox(height: 8),
        const ShimmerLoading(width: 70, height: 14),
        const SizedBox(height: 4),
        const ShimmerLoading(width: 50, height: 12),
        const SizedBox(height: 8),
        ShimmerLoading(width: 80, height: height, borderRadius: 8),
      ],
    );
  }
}

// ============================================================================
// CITIZENS SKELETON - Citizens list skeleton
// ============================================================================

class CitizensSkeleton extends StatelessWidget {
  const CitizensSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          6,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceC(context),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.soft,
              ),
              child: const Row(
                children: [
                  ShimmerLoading(width: 48, height: 48, borderRadius: 24),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoading(width: 120, height: 14),
                        SizedBox(height: 6),
                        ShimmerLoading(width: 80, height: 12),
                      ],
                    ),
                  ),
                  ShimmerLoading(width: 60, height: 24, borderRadius: 12),
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
// NOTIFICATIONS SKELETON - Notification list skeleton
// ============================================================================

class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter tabs skeleton
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ShimmerLoading(width: 60, height: 32, borderRadius: 16),
                SizedBox(width: 8),
                ShimmerLoading(width: 80, height: 32, borderRadius: 16),
                SizedBox(width: 8),
                ShimmerLoading(width: 70, height: 32, borderRadius: 16),
                SizedBox(width: 8),
                ShimmerLoading(width: 90, height: 32, borderRadius: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Notification items
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceC(context),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.soft,
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: 40, height: 40, borderRadius: 12),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoading(width: 140, height: 14),
                          SizedBox(height: 8),
                          ShimmerLoading(height: 12),
                          SizedBox(height: 4),
                          ShimmerLoading(width: 180, height: 12),
                          SizedBox(height: 8),
                          ShimmerLoading(width: 60, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DONATE SKELETON - Donation page skeleton
// ============================================================================

class DonateSkeleton extends StatelessWidget {
  const DonateSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceC(context),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.soft,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(width: 100, height: 16),
                SizedBox(height: 12),
                ShimmerLoading(height: 14),
                SizedBox(height: 6),
                ShimmerLoading(width: 200, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerLoading(width: 140, height: 18),
          const SizedBox(height: 16),
          // Payment method cards
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 80,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceC(context),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.soft,
                ),
                child: const Row(
                  children: [
                    ShimmerLoading(width: 48, height: 48, borderRadius: 12),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoading(width: 80, height: 14),
                          SizedBox(height: 8),
                          ShimmerLoading(width: 140, height: 12),
                        ],
                      ),
                    ),
                    ShimmerLoading(width: 24, height: 24, borderRadius: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PROBLEMS SKELETON - Problems list skeleton
// ============================================================================

class ProblemsSkeleton extends StatelessWidget {
  const ProblemsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceC(context),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.soft,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShimmerLoading(width: 44, height: 44, borderRadius: 12),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading(width: 100, height: 14),
                            SizedBox(height: 6),
                            ShimmerLoading(width: 70, height: 12),
                          ],
                        ),
                      ),
                      ShimmerLoading(width: 70, height: 24, borderRadius: 12),
                    ],
                  ),
                  SizedBox(height: 14),
                  ShimmerLoading(height: 14),
                  SizedBox(height: 6),
                  ShimmerLoading(width: 200, height: 14),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      ShimmerLoading(width: 60, height: 28, borderRadius: 14),
                      SizedBox(width: 12),
                      ShimmerLoading(width: 60, height: 28, borderRadius: 14),
                    ],
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
// PROJECTS SKELETON - Projects grid skeleton
// ============================================================================

class ProjectsSkeleton extends StatelessWidget {
  const ProjectsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceC(context),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      ShimmerLoading(width: 48, height: 48, borderRadius: 14),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading(width: 140, height: 16),
                            SizedBox(height: 8),
                            ShimmerLoading(width: 80, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ShimmerLoading(height: 12),
                  const SizedBox(height: 6),
                  const ShimmerLoading(width: 180, height: 12),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const ShimmerLoading(height: 8),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerLoading(width: 70, height: 12),
                      ShimmerLoading(width: 40, height: 12),
                    ],
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
        color: AppColors.errorC(context).withValues(alpha: 0.15),
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
        color: color == null ? AppColors.surfaceC(context) : AppColors.primaryC(context),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryC(context),
            letterSpacing: -0.3,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryC(context),
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

// ============================================================================
// PREMIUM TEXT FIELD - Styled text input field
// ============================================================================

class PremiumTextField extends StatelessWidget {
  const PremiumTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(fontSize: 15, color: AppColors.textPrimaryC(context)),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondaryC(context)),
        labelStyle: TextStyle(fontSize: 14, color: AppColors.textSecondaryC(context)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textTertiaryC(context), size: 22)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? AppColors.surfaceC(context) : AppColors.surfaceVariantC(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryC(context), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.errorC(context), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.errorC(context), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

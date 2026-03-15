import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models.dart';

final NumberFormat currency = NumberFormat.currency(
  locale: 'bn_BD',
  symbol: '৳',
);
final DateFormat shortDate = DateFormat('dd MMM yyyy');

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final compactLayout = MediaQuery.of(context).size.width <= 360;
    final resolvedPadding =
        padding ?? EdgeInsets.all(compactLayout ? 14 : 16);
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(padding: resolvedPadding, child: child),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final normalized = text.toLowerCase();
    final Color color;
    final Color bg;
    if (normalized.contains('completed')) {
      color = const Color(0xFF059669);
      bg = const Color(0xFFECFDF5);
    } else if (normalized.contains('progress')) {
      color = const Color(0xFFD97706);
      bg = const Color(0xFFFFFBEB);
    } else if (normalized.contains('urgent') ||
        normalized.contains('pending')) {
      color = const Color(0xFFDC2626);
      bg = const Color(0xFFFEF2F2);
    } else if (normalized.contains('planning')) {
      color = const Color(0xFF2563EB);
      bg = const Color(0xFFEFF6FF);
    } else {
      color = const Color(0xFF64748B);
      bg = const Color(0xFFF1F5F9);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
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

class FundProgressCard extends StatelessWidget {
  const FundProgressCard({super.key, required this.overview});

  final VillageOverview overview;

  @override
  Widget build(BuildContext context) {
    final total = overview.totalFundCollected;
    final spent = overview.totalSpent;
    final progress = total <= 0 ? 0.0 : (spent / total).clamp(0.0, 1.0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Village Fund Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _metricColumn('Collected', currency.format(total), const Color(0xFFFF9500))),
              Container(width: 1, height: 40, color: const Color(0xFFF2F2F7)),
              Expanded(child: _metricColumn('Spent', currency.format(spent), const Color(0xFFDC2626))),
              Container(width: 1, height: 40, color: const Color(0xFFF2F2F7)),
              Expanded(child: _metricColumn('Balance', currency.format(overview.availableBalance), const Color(0xFF059669))),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: const Color(0xFFF2F2F7)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF9500), Color(0xFFFFBE45)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of total fund utilized',
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _metricColumn(String label, String value, Color accent) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, color: accent, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

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
                      color: const Color(0xFF1C1C1E),
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
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
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
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 6,
                      child: Stack(
                        children: [
                          Container(color: const Color(0xFFF2F2F7)),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFF9500), Color(0xFFFFBE45)],
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
                    color: Color(0xFFFF9500),
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
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1C1C1E))),
        ],
      ),
    );
  }
}

class DonationCard extends StatelessWidget {
  const DonationCard({super.key, required this.item, this.compact = false});

  final Donation item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.volunteer_activism, color: Color(0xFFFF9500), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.donorName,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.paymentMethod} · ${shortDate.format(item.createdAt)}',
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          currency.format(item.amount),
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669), fontSize: 15),
        ),
      ],
    );

    if (compact) {
      return SizedBox(width: 310, child: AppCard(child: content));
    }

    return AppCard(child: content);
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width <= 360;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: const Color(0xFF1C1C1E),
              fontSize: compact ? 16 : 18,
            ),
          ),
        ),
        ...[trailing].whereType<Widget>(),
      ],
    );
  }
}

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 10,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.95).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 110});

  final double height;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        height: height,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 160, height: 16),
            SizedBox(height: 10),
            SkeletonBox(height: 14),
            SizedBox(height: 8),
            SkeletonBox(width: 120, height: 14),
          ],
        ),
      ),
    );
  }
}

class AnimatedEntry extends StatefulWidget {
  const AnimatedEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.06),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : widget.offset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}

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
              color: const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFFF9500), size: 26),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF1C1C1E))),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
        ],
      ),
    );
  }
}

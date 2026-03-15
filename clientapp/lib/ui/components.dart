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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(item.amount),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669), fontSize: 15),
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

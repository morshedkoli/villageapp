import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../models.dart';

class AllDonationsScreen extends ConsumerStatefulWidget {
  const AllDonationsScreen({super.key});

  @override
  ConsumerState<AllDonationsScreen> createState() => _AllDonationsScreenState();
}

class _AllDonationsScreenState extends ConsumerState<AllDonationsScreen> {
  final _fmt = NumberFormat('#,##0');
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _sort = 'newest'; // newest | highest

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Donation> _apply(List<Donation> all) {
    var list = all.where((d) {
      if (_search.isEmpty) return true;
      return d.donorName.toLowerCase().contains(_search) ||
          d.amount.toString().contains(_search) ||
          d.paymentMethod.toLowerCase().contains(_search);
    }).toList();

    if (_sort == 'newest') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      list.sort((a, b) => b.amount.compareTo(a.amount));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(donationsProvider);

    return Scaffold(
      backgroundColor: context.canvas,
      appBar: AppBar(
        title: const Text('সকল দান'),
        backgroundColor: context.surface,
        foregroundColor: context.textPrimary,
        elevation: 0,
        actions: [
          _SortButton(current: _sort, onChange: (v) => setState(() => _sort = v)),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
        data: (all) {
          final filtered = _apply(all);
          final total = filtered.fold<double>(0, (s, d) => s + d.amount);

          return Column(
            children: [
              // ── Search bar ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'দাতার নাম বা পরিমাণ অনুসন্ধান...',
                    prefixIcon: Icon(Icons.search, color: context.textSecondary),
                    filled: true,
                    fillColor: context.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),

              // ── Summary chip ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.receipt_long_rounded,
                      label: '${filtered.length} টি দান',
                      color: AppColors.primary,
                    ),
                    AppSpacing.wMd,
                    _SummaryChip(
                      icon: Icons.volunteer_activism_rounded,
                      label: '৳${_fmt.format(total)}',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),

              // ── List ──────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('কোনো দান পাওয়া যায়নি'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (ctx, i) => _DonationTile(
                          donation: filtered[i],
                          fmt: _fmt,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────

class _DonationTile extends StatelessWidget {
  final Donation donation;
  final NumberFormat fmt;

  const _DonationTile({required this.donation, required this.fmt});

  Color _statusColor(String s) {
    switch (s) {
      case 'Approved': return AppColors.success;
      case 'Rejected': return AppColors.error;
      default:         return AppColors.warning;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'Approved': return 'অনুমোদিত';
      case 'Rejected': return 'বাতিল';
      default:         return 'অপেক্ষমাণ';
    }
  }

  String _initials(String name) =>
      name.isNotEmpty ? name.characters.first : '?';

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(donation.status);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          AvatarWidget(initials: _initials(donation.donorName), size: 44),
          AppSpacing.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.donorName,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${donation.paymentMethod} • ${dateFmt.format(donation.createdAt)}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _statusLabel(donation.status),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.wMd,
          Text(
            '৳${fmt.format(donation.amount)}',
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SummaryChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String current;
  final void Function(String) onChange;
  const _SortButton({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'সাজান',
      onSelected: onChange,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'newest',
          child: Row(children: [
            if (current == 'newest') const Icon(Icons.check, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('সর্বশেষ প্রথমে'),
          ]),
        ),
        PopupMenuItem(
          value: 'highest',
          child: Row(children: [
            if (current == 'highest') const Icon(Icons.check, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('সর্বোচ্চ পরিমাণ প্রথমে'),
          ]),
        ),
      ],
    );
  }
}

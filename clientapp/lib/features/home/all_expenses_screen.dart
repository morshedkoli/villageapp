import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models.dart';

class AllExpensesScreen extends ConsumerStatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  ConsumerState<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends ConsumerState<AllExpensesScreen> {
  final _amtFmt = NumberFormat('#,##0');
  final _dateFmt = DateFormat('d MMM y', 'bn');

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(dashboardProvider);
    final filteredExpensesAsync = ref.watch(filteredExpensesProvider);
    final totalExpensesAsync = ref.watch(totalExpensesProvider);
    final newestFirst = ref.watch(expenseSortNewestFirstProvider);

    if (dashAsync.isLoading || filteredExpensesAsync.isLoading || totalExpensesAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (dashAsync.hasError) {
      return Scaffold(body: Center(child: Text('ত্রুটি: ${dashAsync.error}')));
    }
    if (filteredExpensesAsync.hasError) {
      return Scaffold(body: Center(child: Text('ত্রুটি: ${filteredExpensesAsync.error}')));
    }
    if (totalExpensesAsync.hasError) {
      return Scaffold(body: Center(child: Text('ত্রুটি: ${totalExpensesAsync.error}')));
    }

    final overview = dashAsync.requireValue;
    final filtered = filteredExpensesAsync.requireValue;
    final totalFromTx = totalExpensesAsync.requireValue;

    final displayTotal = overview.totalSpent > 0
        ? overview.totalSpent
        : totalFromTx;

    return Scaffold(
      backgroundColor: context.canvas,
      appBar: AppBar(
        title: const Text('মোট ব্যয়'),
        backgroundColor: context.surface,
        foregroundColor: context.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 20,
            ),
            tooltip: newestFirst ? 'নতুন আগে' : 'পুরনো আগে',
            onPressed: () => ref.read(expenseSortNewestFirstProvider.notifier).setSort(!newestFirst),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Summary card ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(Icons.payments_rounded,
                          color: Colors.white, size: 26),
                    ),
                    AppSpacing.wLg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('মোট ব্যয়',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '৳${_amtFmt.format(displayTotal)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('ব্যালেন্স',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '৳${_amtFmt.format(overview.availableBalance)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            '${filtered.length} টি লেনদেন',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search bar ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'প্রকল্প বা বিবরণ খুঁজুন…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.card,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) => ref.read(expenseSearchQueryProvider.notifier).setQuery(v),
              ),
            ),
          ),

          // ── Section label ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm,
                AppSpacing.lg, AppSpacing.md,
              ),
              child: Text(
                filtered.isEmpty
                    ? 'কোনো ফলাফল নেই'
                    : 'ব্যয়ের বিবরণ (${filtered.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),

          // ── List ──────────────────────────────────
          if (filtered.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'কোনো ব্যয়ের রেকর্ড পাওয়া যায়নি\n(অ্যাডমিন প্যানেল থেকে ব্যয় যোগ করুন)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i.isOdd) {
                      return const SizedBox(height: AppSpacing.sm);
                    }
                    return _ExpenseTile(
                      tx: filtered[i ~/ 2],
                      totalSpent: displayTotal,
                      amtFmt: _amtFmt,
                      dateFmt: _dateFmt,
                    );
                  },
                  childCount: filtered.length * 2 - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


// ─── Expense tile ─────────────────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final FundTransaction tx;
  final double totalSpent;
  final NumberFormat amtFmt;
  final DateFormat dateFmt;

  const _ExpenseTile({
    required this.tx,
    required this.totalSpent,
    required this.amtFmt,
    required this.dateFmt,
  });

  String _typeLabel(String type) {
    switch (type) {
      case 'expense':         return 'ব্যয়';
      case 'project_expense': return 'প্রকল্প ব্যয়';
      case 'salary':          return 'বেতন';
      case 'maintenance':     return 'রক্ষণাবেক্ষণ';
      default:                return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = totalSpent > 0
        ? (tx.amount / totalSpent).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.payments_rounded,
                    size: 22, color: AppColors.error),
              ),
              AppSpacing.wMd,

              // Title + type badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.reference.isNotEmpty ? tx.reference : 'ব্যয়',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            _typeLabel(tx.type),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateFmt.format(tx.createdAt),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                '৳${amtFmt.format(tx.amount)}',
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Note
          if (tx.note.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              tx.note,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Share of total bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: context.border,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.error),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(pct * 100).toStringAsFixed(1)}% মোট ব্যয়ের',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

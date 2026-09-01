import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/providers.dart';
import '../../models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/login_prompt.dart';
import '../../core/widgets/loading_shimmer.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleanNumber.isEmpty) return;
  final uri = Uri.parse('tel:$cleanNumber');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('কল সংযোগ করা সম্ভব হচ্ছে না')),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কল সংযোগ করা সম্ভব হচ্ছে না')),
      );
    }
  }
}

Future<void> _sendSms(BuildContext context, String phoneNumber) async {
  final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleanNumber.isEmpty) return;
  final uri = Uri.parse('sms:$cleanNumber');
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('বার্তা পাঠানো সম্ভব হচ্ছে না')),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বার্তা পাঠানো সম্ভব হচ্ছে না')),
      );
    }
  }
}

class CitizenDirectoryScreen extends ConsumerStatefulWidget {
  const CitizenDirectoryScreen({super.key});

  @override
  ConsumerState<CitizenDirectoryScreen> createState() => _CitizenDirectoryScreenState();
}

class _CitizenDirectoryScreenState extends ConsumerState<CitizenDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;

  final List<String> _filters = [
    'সব',
    'ছাত্র',
    'শিক্ষক',
    'কৃষক',
    'ব্যবসায়ী',
    'ডাক্তার',
  ];

  List<Citizen> _filtered(List<Citizen> citizens) {
    final filtered = _selectedFilter == 0
        ? citizens
        : citizens.where((c) => c.profession == _filters[_selectedFilter]).toList();

    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return filtered;

    return filtered.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.village.toLowerCase().contains(query) ||
          c.phone.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citizensAsync = ref.watch(citizensProvider);
    final isAuthenticated = ref
        .watch(isAuthenticatedProvider)
        .when(data: (v) => v, error: (_, __) => false, loading: () => false);

    return Scaffold(
      backgroundColor: context.canvas,
      appBar: AppBar(
        title: const Text('নাগরিক তালিকা'),
      ),
      body: citizensAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: ListSkeleton(itemCount: 6),
        ),
        error: (e, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'নাগরিক তথ্য লোড করা যায়নি',
            subtitle: 'ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন',
            actionLabel: 'পুনরায় লোড করুন',
            onAction: () => ref.invalidate(citizensProvider),
          ),
        ),
        data: (citizens) {
          final filtered = _filtered(citizens);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'নাগরিক অনুসন্ধান করুন...',
                    prefixIcon: Icon(Icons.search, color: context.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: context.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(
                        color: context.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => AppSpacing.wSm,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilter == index;
                    return ChoiceChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedFilter = index),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.primary : context.textSecondary,
                      ),
                      backgroundColor: context.card,
                      selectedColor: AppColors.primary.withValues(alpha: 0.12),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    );
                  },
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        title: 'কোনো নাগরিক পাওয়া যায়নি',
                        description: 'অনুসন্ধানের সাথে মিলে এমন কেউ নেই',
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: context.surface,
                        onRefresh: () async {
                          ref.invalidate(citizensProvider);
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.massive,
                          ),
                          itemCount: filtered.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.70,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          itemBuilder: (context, index) {
                            final citizen = filtered[index];
                            return _CitizenCard(
                              citizen: citizen,
                              isAuthenticated: isAuthenticated,
                              onTap: () => context.push('/citizens/${citizen.id}'),
                              onCall: () {
                                if (isAuthenticated) {
                                  _makePhoneCall(context, citizen.phone);
                                } else {
                                  showLoginPrompt(
                                    context,
                                    reason: 'ফোন নম্বর দেখতে ও কল করতে লগইন করুন',
                                    onSuccess: () {
                                      _makePhoneCall(context, citizen.phone);
                                    },
                                  );
                                }
                              },
                              onMessage: () {
                                if (isAuthenticated) {
                                  _sendSms(context, citizen.phone);
                                } else {
                                  showLoginPrompt(
                                    context,
                                    reason: 'বার্তা পাঠাতে লগইন করুন',
                                    onSuccess: () {
                                      _sendSms(context, citizen.phone);
                                    },
                                  );
                                }
                              },
                            );
                          },
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

class _CitizenCard extends StatelessWidget {
  final Citizen citizen;
  final bool isAuthenticated;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const _CitizenCard({
    required this.citizen,
    required this.isAuthenticated,
    required this.onTap,
    required this.onCall,
    required this.onMessage,
  });

  String _initials(String name) {
    if (name.isEmpty) return '';
    return name.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.98,
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                AvatarWidget(
                  initials: _initials(citizen.name),
                  size: 52,
                  showOnline: false,
                ),
                AppSpacing.hSm,
                Text(
                  citizen.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  citizen.profession.isNotEmpty ? citizen.profession : 'নাগরিক',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: context.textTertiary),
                    AppSpacing.wXs,
                    Flexible(
                      child: Text(
                        citizen.village.isNotEmpty ? citizen.village : 'গ্রাম',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.textTertiary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Phone: visible only when authenticated
                if (isAuthenticated && citizen.phone.isNotEmpty)
                  Text(
                    citizen.phone,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 11, color: context.textTertiary),
                      AppSpacing.wXs,
                      Text(
                        'লগইন করুন',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Column(
              children: [
                Container(
                  height: 1,
                  color: context.isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: isAuthenticated
                          ? Icons.phone_outlined
                          : Icons.lock_outline_rounded,
                      tooltip: 'কল করুন',
                      color: isAuthenticated ? AppColors.primary : context.textTertiary,
                      onTap: onCall,
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: context.isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    ),
                    _ActionButton(
                      icon: isAuthenticated
                          ? Icons.message_outlined
                          : Icons.lock_outline_rounded,
                      tooltip: 'বার্তা পাঠান',
                      color: isAuthenticated ? AppColors.info : context.textTertiary,
                      onTap: onMessage,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.90,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: context.isDark ? 0.16 : 0.10),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}


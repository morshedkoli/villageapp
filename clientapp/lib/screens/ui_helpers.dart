part of '../screens.dart';

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.balance,
    required this.expense,
    required this.citizens,
  });

  final String title;
  final String balance;
  final String expense;
  final int citizens;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceC(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.borderC(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Village identity header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryC(context).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  size: 16,
                  color: AppColors.primaryC(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiaryC(context),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantC(context),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 12,
                      color: AppColors.textSecondaryC(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$citizens',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryC(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Balance label
          Text(
            tr('Available balance', 'উপলব্ধ ব্যালেন্স'),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiaryC(context),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          // Balance figure (the hero number)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              balance,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryC(context),
                letterSpacing: -0.6,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.borderLightC(context)),
          const SizedBox(height: 12),
          // Spent line
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tr('Total spent', 'মোট ব্যয়'),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryC(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                expense,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryC(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceC(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderC(context), width: 1),
          ),
          child: Icon(icon, color: AppColors.textPrimaryC(context), size: 18),
        ),
      ),
    );
  }
}

/// Notification button with unread badge indicator.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: DataService.instance.unreadNotificationCount(),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _HeaderActionButton(
              icon: Icons.notifications_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
            ),
            if (count > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorC(context),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.surfaceC(context), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      count >= 10 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Host widget that displays in-app notification banners.
/// Wraps around the app body and listens to PushNotificationService.inAppNotificationStream.
class _NotificationBannerHost extends StatefulWidget {
  const _NotificationBannerHost({required this.child});
  final Widget child;

  @override
  State<_NotificationBannerHost> createState() =>
      _NotificationBannerHostState();
}

class _NotificationBannerHostState extends State<_NotificationBannerHost>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  AppNotification? _currentNotification;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    PushNotificationService.instance.inAppNotificationStream.listen(
      _onNotification,
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onNotification(AppNotification notification) {
    if (!mounted) return;

    setState(() {
      _currentNotification = notification;
    });

    _controller.forward();

    // Auto-dismiss after 4 seconds
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  void _onTap() {
    _controller.reverse();
    if (mounted && _currentNotification != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'donation':
        return const Color(0xFFFF9500);
      case 'problem':
        return const Color(0xFFFF3B30);
      case 'citizen':
        return const Color(0xFF34C759);
      default:
        return const Color(0xFF007AFF);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'donation':
        return Icons.volunteer_activism_outlined;
      case 'problem':
        return Icons.report_problem_outlined;
      case 'citizen':
        return Icons.person_add_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentNotification != null)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: _onTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceC(context),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.primaryGlow(0.15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _getTypeColor(
                            _currentNotification!.type,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(_currentNotification!.type),
                          color: _getTypeColor(_currentNotification!.type),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentNotification!.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryC(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_currentNotification!.body.isNotEmpty)
                              Text(
                                _currentNotification!.body,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryC(context),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondaryC(context).withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

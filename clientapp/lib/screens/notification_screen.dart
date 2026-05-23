part of '../screens.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _filter = 'All';
  final Set<String> _autoMarkedIds = <String>{};

  void _markVisibleNotificationsAsRead(
    List<AppNotification> visible,
    Set<String> readIds,
  ) {
    final user = DataService.instance.currentUser;
    if (user == null) return;

    final unreadVisibleIds = visible
        .map((n) => n.id)
        .where((id) => !readIds.contains(id) && !_autoMarkedIds.contains(id))
        .toList();

    if (unreadVisibleIds.isEmpty) return;

    _autoMarkedIds.addAll(unreadVisibleIds);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await DataService.instance.markAllNotificationsRead(unreadVisibleIds);
      } catch (_) {
        // Ignore transient failures; stream updates will retry on next rebuild.
      }
    });
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'donation':
        return AppColors.primaryC(context);
      case 'problem':
        return AppColors.errorC(context);
      case 'citizen':
      case 'registration':
        return AppColors.successC(context);
      case 'project':
        return AppColors.infoC(context);
      default:
        return AppColors.secondary;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'donation':
        return Icons.volunteer_activism_outlined;
      case 'problem':
        return Icons.report_problem_outlined;
      case 'citizen':
      case 'registration':
        return Icons.person_add_outlined;
      case 'project':
        return Icons.construction_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = DataService.instance;
    return StreamBuilder<List<AppNotification>>(
      stream: data.notifications(limit: 120),
      builder: (context, notifSnap) {
        if (notifSnap.connectionState == ConnectionState.waiting &&
            !notifSnap.hasData) {
          return _SidebarPageScaffold(
            title: tr('Notifications', 'নোটিফিকেশন'),
            subtitle: tr('Updates and alerts', 'আপডেট এবং সতর্কতা'),
            selectedId: _MenuId.notifications,
            body: const NotificationsSkeleton(),
          );
        }
        final notifications = notifSnap.data ?? const <AppNotification>[];
        return StreamBuilder<Set<String>>(
          stream: data.myReadNotificationIds(),
          builder: (context, readSnap) {
            final readIds = readSnap.data ?? <String>{};
            final filtered = notifications.where((n) {
              if (_filter == 'Read') return readIds.contains(n.id);
              if (_filter == 'Unread') return !readIds.contains(n.id);
              return true;
            }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final unreadCount = notifications
                .where((n) => !readIds.contains(n.id))
                .length;

            _markVisibleNotificationsAsRead(filtered, readIds);

            return _SidebarPageScaffold(
              title: tr('Notifications', 'নোটিফিকেশন'),
              subtitle: tr(
                'Review recent alerts, donations, and issue updates',
                'সাম্প্রতিক সতর্কতা, অনুদান, এবং সমস্যা আপডেট দেখুন',
              ),
              selectedId: _MenuId.notifications,
              actions: [
                _ShellIconButton(
                  icon: Icons.done_all_rounded,
                  onTap: () async {
                    if (unreadCount == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr(
                              'All notifications are already read',
                              'সব নোটিফিকেশন ইতোমধ্যে পঠিত',
                            ),
                          ),
                        ),
                      );
                      return;
                    }
                    final ok = await _ensureLogin(context);
                    if (!context.mounted || !ok) return;
                    await data.markAllNotificationsRead(
                      notifications.map((e) => e.id),
                    );
                  },
                ),
              ],
              body: _constrainBodyWidth(
                context,
                ListView(
                  padding: _pagePadding(context).copyWith(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  children: [
                    _PageBanner(
                      title: tr('Notification Center', 'নোটিফিকেশন কেন্দ্র'),
                      subtitle: tr(
                        'Stay informed about village updates',
                        'গ্রামের সব গুরুত্বপূর্ণ আপডেট দেখুন',
                      ),
                      count: tr('$unreadCount unread', '$unreadCount অপঠিত'),
                      icon: Icons.notifications_active_rounded,
                      color: AppColors.primaryC(context),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<String>(
                          showSelectedIcon: false,
                          selected: {_filter},
                          onSelectionChanged: (v) =>
                              setState(() => _filter = v.first),
                          segments: [
                            ButtonSegment(
                              value: 'All',
                              label: Text(tr('All', 'সব')),
                            ),
                            ButtonSegment(
                              value: 'Unread',
                              label: Text(tr('Unread', 'অপঠিত')),
                            ),
                            ButtonSegment(
                              value: 'Read',
                              label: Text(tr('Read', 'পঠিত')),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (filtered.isEmpty)
                      EmptyStateCard(
                        icon: Icons.notifications_off_outlined,
                        title: tr('No notifications', 'কোনো নোটিফিকেশন নেই'),
                        message: tr(
                          'There are no updates in this filter right now.',
                          'এই ফিল্টারে এখন কোনো আপডেট নেই।',
                        ),
                        actionLabel: tr('Go Home', 'হোমে যান'),
                        action: () => _openRootTab(context, 0),
                      )
                    else
                      ...filtered.map((n) {
                        final isRead = readIds.contains(n.id);
                        final color = _colorFor(n.type);
                        return AppCard(
                          backgroundColor: isRead
                              ? AppColors.surfaceC(context)
                              : AppColors.primaryMutedC(context).withValues(alpha: 0.28),
                          child: ListTile(
                            onTap: () async {
                              if (isRead) return;
                              final ok = await _ensureLogin(context);
                              if (!context.mounted || !ok) return;
                              await data.markNotificationRead(n.id);
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _iconFor(n.type),
                                color: color,
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryC(context),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (!isRead) const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    n.title.isNotEmpty
                                        ? n.title
                                        : n.body.isNotEmpty
                                        ? n.body
                                        : 'Village update available',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.textPrimaryC(context),
                                      fontWeight: isRead
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (n.title.isNotEmpty && n.body.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      n.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                Text(
                                  DateFormat(
                                    'dd MMM, hh:mm a',
                                  ).format(n.createdAt),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                final ok = await _ensureLogin(context);
                                if (!context.mounted || !ok) return;
                                if (isRead) {
                                  await data.markNotificationUnread(n.id);
                                } else {
                                  await data.markNotificationRead(n.id);
                                }
                              },
                              icon: Icon(
                                isRead
                                    ? Icons.mark_email_read_outlined
                                    : Icons.mark_email_unread_outlined,
                                color: isRead
                                    ? AppColors.textTertiaryC(context)
                                    : AppColors.primaryC(context),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

part of '../screens.dart';


class CitizensPage extends StatelessWidget {
  const CitizensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SidebarPageScaffold(
      title: tr('Citizens', 'নাগরিক'),
      subtitle: tr(
        'Browse registered people, professions, and villages',
        'নিবন্ধিত মানুষ, পেশা, এবং গ্রামগুলো দেখুন',
      ),
      selectedId: _MenuId.citizens,
      actions: const [_NotificationButton()],
      body: const CitizensScreen(),
    );
  }
}

class CitizensScreen extends StatefulWidget {
  const CitizensScreen({super.key});

  @override
  State<CitizensScreen> createState() => _CitizensScreenState();
}

class _CitizensScreenState extends State<CitizensScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Citizen>>(
      stream: DataService.instance.citizens(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const CitizensSkeleton();
        }
        if (snap.hasError) {
          return ListView(
            padding: _pagePadding(context),
            children: [
              EmptyStateCard(
                icon: Icons.error_outline_rounded,
                title: tr(
                  'Could not load citizens',
                  'নাগরিক তালিকা লোড করা যায়নি',
                ),
                message: '${snap.error}',
              ),
            ],
          );
        }
        final all = snap.data ?? const <Citizen>[];
        final q = _search.text.trim().toLowerCase();
        final filtered = all
            .where(
              (c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.profession.toLowerCase().contains(q) ||
                  c.village.toLowerCase().contains(q),
            )
            .toList();

        return ListView(
          padding: _pagePadding(context),
          children: [
            _PageBanner(
              title: tr('Village Citizens', 'গ্রামের নাগরিক'),
              subtitle: tr(
                'Browse all registered members',
                'সব নিবন্ধিত সদস্য দেখুন',
              ),
              count: '${all.length} ${tr('citizens', 'নাগরিক')}',
              icon: Icons.people_rounded,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 14),
            PremiumTextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              hintText: tr(
                'Search name or profession',
                'নাম বা পেশা লিখে খুঁজুন',
              ),
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              EmptyStateCard(
                icon: Icons.search_off,
                title: tr('No matching citizens', 'মিলছে এমন নাগরিক নেই'),
                message: tr(
                  'Try a different name or profession keyword.',
                  'অন্য নাম বা পেশার কীওয়ার্ড চেষ্টা করুন।',
                ),
              )
            else
              ...filtered.map((c) => _CitizenCard(citizen: c)),
          ],
        );
      },
    );
  }
}

// ─── Citizen Card ────────────────────────────────────────────────────────────

class _CitizenCard extends StatelessWidget {
  const _CitizenCard({required this.citizen});

  final Citizen citizen;

  Future<void> _call(BuildContext context) async {
    final phone = citizen.phone.trim().replaceAll(' ', '');
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('Could not open dialer', 'ডায়ালার খুলতে পারা যায়নি'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = citizen;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            // Avatar
            c.photoUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(c.photoUrl),
                  )
                : Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.secondaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        c.name.isEmpty ? '?' : c.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryC(context),
                    ),
                  ),
                  if (c.profession.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.work_outline_rounded,
                            size: 12, color: AppColors.textTertiaryC(context)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            c.profession,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryC(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (c.village.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 12, color: AppColors.primaryC(context)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            c.village,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryC(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (c.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      c.phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiaryC(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Call button
            if (c.phone.isNotEmpty) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _call(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34C759), Color(0xFF28A745)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34C759).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.call_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

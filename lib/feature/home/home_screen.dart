import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/water_provider.dart';
import '../../core/providers/user_provider.dart';
import '../add_water/add_water_modal.dart';
import '../statistics/statistics_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/water_progress_ring.dart';
import 'widgets/quick_add_buttons.dart';
import 'widgets/daily_history_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterProvider>().refreshToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tabs = [
      _buildHomeTab(l10n),
      const StatisticsScreen(),
      const SettingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedTab,
        children: tabs,
      ),
      bottomNavigationBar: _buildBottomNav(l10n),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton(
              onPressed: () => AddWaterModal.show(context),
              backgroundColor: AppColors.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeTab(AppLocalizations l10n) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(l10n),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const WaterProgressRing(),
              const SizedBox(height: 32),
              QuickAddButtons(
                onAddCustom: () => AddWaterModal.show(context),
              ),
              const SizedBox(height: 24),
              const DailyHistoryList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l10n) {
    final userProvider = context.watch<UserProvider>();
    final waterProvider = context.watch<WaterProvider>();

    String greeting;
    final greetingKey = userProvider.greeting;
    switch (greetingKey) {
      case 'home_greeting_morning':
        greeting = l10n.homeGreetingMorning;
        break;
      case 'home_greeting_afternoon':
        greeting = l10n.homeGreetingAfternoon;
        break;
      default:
        greeting = l10n.homeGreetingEvening;
    }

    final name = userProvider.profile.name;

    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      snap: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$greeting${name.isNotEmpty ? ', $name!' : '!'}',
                        style: AppTextStyles.headingSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.homeTodayIntake,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Goal indicator chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: waterProvider.isGoalReached
                        ? AppColors.successGreen.withOpacity(0.12)
                        : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: waterProvider.isGoalReached
                          ? AppColors.successGreen
                          : AppColors.primaryLight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        waterProvider.isGoalReached
                            ? Icons.check_circle_rounded
                            : Icons.water_drop_rounded,
                        color: waterProvider.isGoalReached
                            ? AppColors.successGreen
                            : AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(waterProvider.progress * 100).toInt()}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: waterProvider.isGoalReached
                              ? AppColors.successGreen
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations l10n) {
    final navItems = [
      (Icons.home_rounded, Icons.home_outlined, l10n.appName.split(' ')[0]),
      (Icons.bar_chart_rounded, Icons.bar_chart_outlined, l10n.statsTitle),
      (Icons.settings_rounded, Icons.settings_outlined, l10n.settingsTitle),
      (Icons.person_rounded, Icons.person_outlined, l10n.profileTitle),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // First 2 tabs
              for (int i = 0; i < 2; i++)
                Expanded(
                  child: _navItem(
                    i,
                    navItems[i].$1,
                    navItems[i].$2,
                    navItems[i].$3,
                  ),
                ),

              // FAB gap
              const SizedBox(width: 64),

              // Last 2 tabs
              for (int i = 2; i < 4; i++)
                Expanded(
                  child: _navItem(
                    i,
                    navItems[i].$1,
                    navItems[i].$2,
                    navItems[i].$3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primarySurface : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/water_provider.dart';
import '../../core/providers/settings_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final water = context.watch<WaterProvider>();
    final settings = context.watch<SettingsProvider>();

    final weeklyData = water.getWeeklyTotals();
    final streak = water.getCurrentStreak();
    final goal = water.dailyGoalMl;

    // Calculate stats
    final weeklyValues = weeklyData.values.toList();
    final totalWeek = weeklyValues.fold(0, (a, b) => a + b);
    final avgDay = weeklyValues.isEmpty ? 0 : (totalWeek / 7).round();
    final bestDay = weeklyValues.isEmpty ? 0 : weeklyValues.reduce((a, b) => a > b ? a : b);
    final daysGoalReached = weeklyValues.where((v) => v >= goal).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelMedium,
          tabs: [
            Tab(text: l10n.statsWeekly),
            Tab(text: l10n.statsMonthly),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyTab(l10n, weeklyData, totalWeek, avgDay, bestDay,
              daysGoalReached, streak, goal, settings),
          _buildMonthlyTab(l10n, water, settings, goal),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab(
    AppLocalizations l10n,
    Map<DateTime, int> weeklyData,
    int totalWeek,
    int avgDay,
    int bestDay,
    int daysGoalReached,
    int streak,
    int goal,
    SettingsProvider settings,
  ) {
    // Day labels
    final dayLabels = [
      l10n.statsDayMon,
      l10n.statsDayTue,
      l10n.statsDayWed,
      l10n.statsDayThu,
      l10n.statsDayFri,
      l10n.statsDaySat,
      l10n.statsDaySun,
    ];

    // Build chart data for Mon-Sun of this week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      final value = weeklyData[dayKey]?.toDouble() ?? 0;
      final isToday = dayKey.day == now.day && dayKey.month == now.month;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: value >= goal
                  ? AppColors.successGreen
                  : (isToday ? AppColors.primary : AppColors.primaryLight),
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: goal.toDouble(),
                color: AppColors.surfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary cards
          Row(
            children: [
              _statCard(
                icon: Icons.local_fire_department_rounded,
                label: l10n.statsStreak,
                value: '$streak',
                unit: l10n.statsStreakDays,
                color: AppColors.warning,
              ),
              const SizedBox(width: 12),
              _statCard(
                icon: Icons.star_rounded,
                label: l10n.statsGoalReached,
                value: '$daysGoalReached',
                unit: l10n.statsGoalReachedDays,
                color: AppColors.successGreen,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard(
                icon: Icons.trending_up_rounded,
                label: l10n.statsAverage,
                value: '${(avgDay / 1000).toStringAsFixed(1)}L',
                unit: '/ dia',
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _statCard(
                icon: Icons.emoji_events_rounded,
                label: l10n.statsBestDay,
                value: settings.formatAmount(bestDay),
                unit: '',
                color: AppColors.warning,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bar chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.statsWeekly, style: AppTextStyles.headingSmall),
                    Text(
                      '${(totalWeek / 1000).toStringAsFixed(1)}L',
                      style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: barGroups.isEmpty
                      ? Center(
                          child: Text(l10n.statsNoData,
                              style: AppTextStyles.bodyMedium))
                      : BarChart(
                          BarChartData(
                            barGroups: barGroups,
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) => Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      dayLabels[value.toInt()],
                                      style: AppTextStyles.caption,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    settings.formatAmount(rod.toY.round()),
                                    AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                // Legend
                Row(
                  children: [
                    _legendDot(AppColors.successGreen),
                    const SizedBox(width: 6),
                    Text('Meta atingida', style: AppTextStyles.caption),
                    const SizedBox(width: 16),
                    _legendDot(AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Hoje', style: AppTextStyles.caption),
                    const SizedBox(width: 16),
                    _legendDot(AppColors.primaryLight),
                    const SizedBox(width: 6),
                    Text('Outros dias', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab(
    AppLocalizations l10n,
    WaterProvider water,
    SettingsProvider settings,
    int goal,
  ) {
    final monthlyData = water.getMonthlyTotals();
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.statsMonthly, style: AppTextStyles.headingSmall),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final day = DateTime(now.year, now.month, index + 1);
                    final total = monthlyData[day] ?? 0;
                    final isGoalReached = total >= goal;
                    final hasData = total > 0;
                    final isToday = day.day == now.day;
                    final isFuture = day.isAfter(now);

                    return Container(
                      decoration: BoxDecoration(
                        color: isFuture
                            ? AppColors.surfaceVariant
                            : isGoalReached
                                ? AppColors.successGreen
                                : hasData
                                    ? AppColors.primaryLight
                                    : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: isToday
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: isGoalReached
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Legend
                Row(
                  children: [
                    _legendDot(AppColors.successGreen),
                    const SizedBox(width: 6),
                    Text('Meta atingida', style: AppTextStyles.caption),
                    const SizedBox(width: 16),
                    _legendDot(AppColors.primaryLight),
                    const SizedBox(width: 6),
                    Text('Parcial', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.headingSmall.copyWith(color: color)),
            if (unit.isNotEmpty)
              Text(unit, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

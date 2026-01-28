import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/water_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared_widget/water_wave_painter.dart';
import '../../../shared_widget/animated_counter.dart';

class WaterProgressRing extends StatefulWidget {
  const WaterProgressRing({super.key});

  @override
  State<WaterProgressRing> createState() => _WaterProgressRingState();
}

class _WaterProgressRingState extends State<WaterProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context);

    final consumed = water.totalConsumedMl;
    final goal = water.dailyGoalMl;
    final progress = water.progress;
    final isGoalReached = water.isGoalReached;

    return Center(
      child: Column(
        children: [
          // Progress circle with wave
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isGoalReached ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: isGoalReached
                          ? AppColors.successGreen
                          : AppColors.primaryLight,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isGoalReached
                                ? AppColors.successGreen
                                : AppColors.primary)
                            .withOpacity(0.15),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

                // Wave fill
                AnimatedWaterWave(
                  fillPercent: progress,
                  size: 208,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isGoalReached)
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.successGreen, size: 32)
                        else ...[
                          AnimatedCounter(
                            value: consumed,
                            style: AppTextStyles.waterAmount.copyWith(
                              fontSize: 42,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          Text(
                            settings.unit == 'oz'
                                ? '${(consumed / 29.5735).toStringAsFixed(0)} oz'
                                : 'ml',
                            style: AppTextStyles.waterUnit,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Goal / Remaining info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoChip(
                icon: Icons.flag_rounded,
                label: l10n.homeGoalLabel,
                value: settings.formatAmount(goal),
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _infoChip(
                icon: Icons.water_drop_rounded,
                label: l10n.homeRemainingLabel,
                value: settings.formatAmount(water.remainingMl),
                color: isGoalReached
                    ? AppColors.successGreen
                    : AppColors.textSecondary,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Motivational message
          Text(
            isGoalReached
                ? l10n.homeGoalReached
                : '${(progress * 100).toInt()}% ${l10n.homeConsumedLabel.toLowerCase()}',
            style: AppTextStyles.labelMedium.copyWith(
              color:
                  isGoalReached ? AppColors.successGreen : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

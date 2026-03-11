import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/water_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<UserProvider>();
    final water = context.watch<WaterProvider>();
    final settings = context.watch<SettingsProvider>();

    final profile = user.profile;
    final streak = water.getCurrentStreak();
    final goal = water.dailyGoalMl;
    final totalConsumed = water.totalConsumedMl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => _editProfile(context, l10n, user, water, settings),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(l10n.profileEditProfile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name
            _buildProfileHeader(profile),
            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                _statCard(
                  icon: Icons.local_fire_department_rounded,
                  label: l10n.statsStreak,
                  value: '$streak',
                  unit: 'dias',
                  color: AppColors.warning,
                ),
                const SizedBox(width: 12),
                _statCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Hoje',
                  value: settings.formatAmount(totalConsumed),
                  unit: '',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard(
                  icon: Icons.flag_rounded,
                  label: l10n.profileDailyGoal,
                  value: settings.formatAmount(goal),
                  unit: '',
                  color: AppColors.darkBlue,
                ),
                const SizedBox(width: 12),
                _statCard(
                  icon: Icons.percent_rounded,
                  label: 'Progresso',
                  value: '${(water.progress * 100).toInt()}%',
                  unit: 'hoje',
                  color: AppColors.successGreen,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Profile details
            _buildProfileDetails(l10n, profile, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty
                    ? profile.name[0].toUpperCase()
                    : '👤',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isNotEmpty ? profile.name : 'Utilizador',
                  style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.age} anos · ${profile.weightKg.toStringAsFixed(0)} kg',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white.withOpacity(0.85)),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.gender == Gender.male ? '♂ Masculino' : '♀ Feminino',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(
    AppLocalizations l10n,
    UserProfile profile,
    SettingsProvider settings,
  ) {
    String activityLabel;
    switch (profile.activityLevel) {
      case ActivityLevel.sedentary:
        activityLabel = l10n.setupActivitySedentary;
        break;
      case ActivityLevel.light:
        activityLabel = l10n.setupActivityLight;
        break;
      case ActivityLevel.moderate:
        activityLabel = l10n.setupActivityModerate;
        break;
      case ActivityLevel.intense:
        activityLabel = l10n.setupActivityIntense;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _detailTile(
            icon: Icons.fitness_center_rounded,
            label: l10n.profileActivity,
            value: activityLabel,
          ),
          const Divider(height: 1),
          _detailTile(
            icon: Icons.monitor_weight_rounded,
            label: l10n.profileWeight,
            value: '${profile.weightKg.toStringAsFixed(0)} kg',
          ),
          const Divider(height: 1),
          _detailTile(
            icon: Icons.cake_rounded,
            label: l10n.profileAge,
            value: '${profile.age} anos',
          ),
          const Divider(height: 1),
          _detailTile(
            icon: Icons.wb_sunny_rounded,
            label: l10n.setupWakeTime,
            value: '${profile.wakeHour.toString().padLeft(2, '0')}:00',
          ),
          const Divider(height: 1),
          _detailTile(
            icon: Icons.nightlight_round,
            label: l10n.setupSleepTime,
            value: '${profile.sleepHour.toString().padLeft(2, '0')}:00',
          ),
        ],
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(label, style: AppTextStyles.bodySmall),
        trailing: Text(value, style: AppTextStyles.labelMedium),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) =>
      Expanded(
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
              Icon(icon, color: color, size: 22),
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

  Future<void> _editProfile(
    BuildContext context,
    AppLocalizations l10n,
    UserProvider user,
    WaterProvider water,
    SettingsProvider settings,
  ) async {
    // Navigate back to setup for editing
    Navigator.pushNamed(context, '/setup');
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/water_provider.dart';
import '../../core/providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final water = context.watch<WaterProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Language ---
          _sectionHeader(l10n.settingsLanguage),
          _card(
            child: _LanguagePicker(
              currentCode: settings.locale.languageCode,
              onChanged: (code) => settings.setLocale(code),
            ),
          ),

          const SizedBox(height: 16),

          // --- Unit ---
          _sectionHeader(l10n.settingsUnit),
          _card(
            child: Column(
              children: [
                _radioTile(
                  title: l10n.settingsUnitMl,
                  value: 'ml',
                  groupValue: settings.unit,
                  onChanged: (v) => settings.setUnit(v!),
                ),
                const Divider(height: 1),
                _radioTile(
                  title: l10n.settingsUnitOz,
                  value: 'oz',
                  groupValue: settings.unit,
                  onChanged: (v) => settings.setUnit(v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- Goal ---
          _sectionHeader(l10n.settingsGoal),
          _card(
            child: Column(
              children: [
                _switchTile(
                  title: l10n.settingsGoalCustom,
                  value: settings.useCustomGoal,
                  onChanged: (v) {
                    settings.setUseCustomGoal(v);
                    if (v) {
                      water.setDailyGoal(settings.customGoalMl);
                    } else {
                      final user = context.read<UserProvider>();
                      water.setDailyGoal(user.calculatedGoal);
                    }
                  },
                ),
                if (settings.useCustomGoal) ...[
                  const Divider(height: 1),
                  _GoalSliderTile(settings: settings, water: water),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- Notifications ---
          _sectionHeader(l10n.settingsNotifications),
          _card(
            child: Column(
              children: [
                _switchTile(
                  title: l10n.settingsNotifEnabled,
                  value: settings.notifEnabled,
                  onChanged: (v) => settings.setNotifEnabled(v),
                ),
                if (settings.notifEnabled) ...[
                  const Divider(height: 1),
                  _IntervalPickerTile(
                    label: l10n.settingsNotifInterval,
                    value: settings.notifIntervalHours,
                    onChanged: (v) => settings.setNotifIntervalHours(v),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- About ---
          _sectionHeader(l10n.settingsAbout),
          _card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary),
                  title: Text(l10n.settingsVersion,
                      style: AppTextStyles.bodyMedium),
                  trailing: Text('2.0.0',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- Reset ---
          _card(
            child: ListTile(
              leading: const Icon(Icons.restart_alt_rounded,
                  color: AppColors.error),
              title: Text(l10n.settingsReset,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error)),
              onTap: () => _showResetConfirm(context, l10n, settings),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );

  Widget _radioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) =>
      RadioListTile<T>(
        title: Text(title, style: AppTextStyles.bodyMedium),
        value: value,
        groupValue: groupValue,
        activeColor: AppColors.primary,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
      );

  Widget _switchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
      );

  Future<void> _showResetConfirm(
    BuildContext context,
    AppLocalizations l10n,
    SettingsProvider settings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsReset),
        content: Text(l10n.settingsResetConfirm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await settings.resetAllData();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/onboard');
      }
    }
  }
}

class _LanguagePicker extends StatelessWidget {
  final String currentCode;
  final ValueChanged<String> onChanged;

  const _LanguagePicker({
    required this.currentCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final langs = [
      ('pt', '🇵🇹', 'Português'),
      ('en', '🇬🇧', 'English'),
      ('fr', '🇫🇷', 'Français'),
      ('de', '🇩🇪', 'Deutsch'),
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: langs.map((lang) {
          final (code, flag, name) = lang;
          final selected = currentCode == code;
          return GestureDetector(
            onTap: () => onChanged(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySurface : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GoalSliderTile extends StatefulWidget {
  final SettingsProvider settings;
  final WaterProvider water;

  const _GoalSliderTile({required this.settings, required this.water});

  @override
  State<_GoalSliderTile> createState() => _GoalSliderTileState();
}

class _GoalSliderTileState extends State<_GoalSliderTile> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.settings.customGoalMl.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Meta personalizada', style: AppTextStyles.bodyMedium),
              Text(
                '${_value.round()} ml',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          Slider(
            value: _value,
            min: 500,
            max: 5000,
            divisions: 45,
            onChanged: (v) => setState(() => _value = v),
            onChangeEnd: (v) {
              widget.settings.setCustomGoalMl(v.round());
              widget.water.setDailyGoal(v.round());
            },
          ),
        ],
      ),
    );
  }
}

class _IntervalPickerTile extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _IntervalPickerTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [1, 2, 3, 4].map((h) {
              final selected = value == h;
              return GestureDetector(
                onTap: () => onChanged(h),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '${h}h',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

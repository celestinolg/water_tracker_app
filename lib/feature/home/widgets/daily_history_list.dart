import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/water_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/models/water_entry.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DailyHistoryList extends StatelessWidget {
  const DailyHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context);

    final entries = water.todayEntries.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.homeHistory, style: AppTextStyles.headingSmall),
              Text(
                settings.formatAmount(water.totalConsumedMl),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        if (entries.isEmpty)
          _buildEmptyState(l10n)
        else
          ...entries.map((entry) => _EntryTile(
                entry: entry,
                displayText: settings.formatAmount(entry.amountMl),
                onDelete: () => water.removeEntry(entry.id),
              )),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.water_drop_outlined,
                color: AppColors.primaryLight, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.homeNoHistory,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final WaterEntry entry;
  final String displayText;
  final VoidCallback onDelete;

  const _EntryTile({
    required this.entry,
    required this.displayText,
    required this.onDelete,
  });

  String _getDrinkName(BuildContext context, DrinkType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case DrinkType.water:
        return l10n.drinkWater;
      case DrinkType.tea:
        return l10n.drinkTea;
      case DrinkType.juice:
        return l10n.drinkJuice;
      case DrinkType.coffee:
        return l10n.drinkCoffee;
      case DrinkType.milk:
        return l10n.drinkMilk;
      case DrinkType.sports:
        return l10n.drinkSports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(entry.timestamp);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Drink icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: entry.drinkColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  entry.drinkEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDrinkName(context, entry.drinkType),
                    style: AppTextStyles.labelMedium,
                  ),
                  Text(timeStr, style: AppTextStyles.bodySmall),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayText,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: entry.drinkColor,
                  ),
                ),
                if (entry.drinkType != DrinkType.water)
                  Text(
                    '≈ ${entry.effectiveMl} ml efetivo',
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

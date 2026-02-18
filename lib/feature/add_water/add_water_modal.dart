import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/water_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/models/water_entry.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared_widget/primary_button/primary_button.dart';

class AddWaterModal extends StatefulWidget {
  const AddWaterModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWaterModal(),
    );
  }

  @override
  State<AddWaterModal> createState() => _AddWaterModalState();
}

class _AddWaterModalState extends State<AddWaterModal>
    with SingleTickerProviderStateMixin {
  int _amountMl = 250;
  DrinkType _drinkType = DrinkType.water;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(l10n.addWaterTitle, style: AppTextStyles.headingSmall),
            const SizedBox(height: 20),

            // Drink type selector
            Text(l10n.addWaterDrinkType, style: AppTextStyles.labelMedium),
            const SizedBox(height: 12),
            _buildDrinkTypeSelector(l10n),
            const SizedBox(height: 24),

            // Amount display
            Text(l10n.addWaterAmount, style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            _buildAmountDisplay(settings),
            const SizedBox(height: 8),

            // Slider
            Slider(
              value: _amountMl.toDouble(),
              min: 50,
              max: 1000,
              divisions: 19,
              label: settings.formatAmount(_amountMl),
              onChanged: (v) => setState(() => _amountMl = v.round()),
            ),

            // Quick preset amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [100, 150, 200, 250, 350, 500].map((ml) {
                final selected = _amountMl == ml;
                return GestureDetector(
                  onTap: () => setState(() => _amountMl = ml),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${ml}ml',
                      style: AppTextStyles.caption.copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Add button
            primaryButton(
              text: '${l10n.addWaterAdd} ${settings.formatAmount(_amountMl)}',
              onPressed: _addWater,
              icon: Icons.add_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkTypeSelector(AppLocalizations l10n) {
    final drinkTypes = [
      (DrinkType.water, l10n.drinkWater, '💧'),
      (DrinkType.tea, l10n.drinkTea, '🍵'),
      (DrinkType.juice, l10n.drinkJuice, '🍊'),
      (DrinkType.coffee, l10n.drinkCoffee, '☕'),
      (DrinkType.milk, l10n.drinkMilk, '🥛'),
      (DrinkType.sports, l10n.drinkSports, '🏃'),
    ];

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: drinkTypes.length,
        itemBuilder: (context, index) {
          final (type, label, emoji) = drinkTypes[index];
          final selected = _drinkType == type;
          return GestureDetector(
            onTap: () => setState(() => _drinkType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySurface : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountDisplay(SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.water_drop_rounded,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            settings.formatAmount(_amountMl),
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.darkBlue,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addWater() async {
    final waterProvider = context.read<WaterProvider>();
    await waterProvider.addEntry(_amountMl, _drinkType);

    if (mounted) {
      Navigator.pop(context);

      final reached = waterProvider.checkAndMarkGoalReached();
      if (reached && context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.homeGoalReachedMessage),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

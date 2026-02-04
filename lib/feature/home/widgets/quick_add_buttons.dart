import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/water_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/models/water_entry.dart';
import '../../../core/l10n/app_localizations.dart';

class QuickAddButtons extends StatelessWidget {
  final VoidCallback onAddCustom;

  const QuickAddButtons({super.key, required this.onAddCustom});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();

    final quickAmounts = [150, 200, 300, 500];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.homeQuickAdd, style: AppTextStyles.headingSmall),
              TextButton.icon(
                onPressed: onAddCustom,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.addWaterCustom,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: quickAmounts.length,
            itemBuilder: (context, index) {
              final ml = quickAmounts[index];
              return _QuickAmountCard(
                amountMl: ml,
                displayText: settings.formatAmount(ml),
                onTap: () => _addWater(context, ml),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addWater(BuildContext context, int ml) async {
    final waterProvider = context.read<WaterProvider>();
    await waterProvider.addEntry(ml, DrinkType.water);

    // Check if goal reached
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

class _QuickAmountCard extends StatefulWidget {
  final int amountMl;
  final String displayText;
  final VoidCallback onTap;

  const _QuickAmountCard({
    required this.amountMl,
    required this.displayText,
    required this.onTap,
  });

  @override
  State<_QuickAmountCard> createState() => _QuickAmountCardState();
}

class _QuickAmountCardState extends State<_QuickAmountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _scaleController.reverse();
    widget.onTap();
    await _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 82,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5DCCFC), Color(0xFF3AB8F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop_rounded, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                widget.displayText,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

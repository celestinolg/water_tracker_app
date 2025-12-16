import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/user_profile.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/water_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/water_calculator.dart';
import '../../shared_widget/primary_button/primary_button.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _step = 0;

  // Form fields
  final _nameController = TextEditingController();
  double _weight = 70;
  int _age = 25;
  ActivityLevel _activity = ActivityLevel.moderate;
  Gender _gender = Gender.male;
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 0);

  bool _isLoading = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _step++);
      _animController.reset();
      _animController.forward();
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);

    final profile = UserProfile(
      name: _nameController.text.trim().isEmpty
          ? 'Utilizador'
          : _nameController.text.trim(),
      weightKg: _weight,
      age: _age,
      activityLevel: _activity,
      gender: _gender,
      wakeHour: _wakeTime.hour,
      sleepHour: _sleepTime.hour,
      isSetupComplete: true,
    );

    final userProvider = context.read<UserProvider>();
    final waterProvider = context.read<WaterProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context);

    await userProvider.saveProfile(profile);
    final goal = WaterCalculator.calculateDailyGoal(profile);
    await waterProvider.setDailyGoal(goal);

    // Schedule notifications
    if (settingsProvider.notifEnabled) {
      await settingsProvider.scheduleNotifications(
        wakeHour: profile.wakeHour,
        sleepHour: profile.sleepHour,
        title: l10n.notifReminderTitle,
        body: l10n.notifReminderBody,
      );
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  UserProfile get _tempProfile => UserProfile(
        name: _nameController.text,
        weightKg: _weight,
        age: _age,
        activityLevel: _activity,
        gender: _gender,
        wakeHour: _wakeTime.hour,
        sleepHour: _sleepTime.hour,
      );

  int get _calculatedGoal => WaterCalculator.calculateDailyGoal(_tempProfile);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPage1(l10n),
                  _buildPage2(l10n),
                  _buildPage3(l10n),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: primaryButton(
                text: _step == 2 ? l10n.setupFinish : l10n.next,
                onPressed: _nextStep,
                isLoading: _isLoading,
                icon: _step == 2 ? Icons.check_rounded : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _step > 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: AppColors.primary, size: 20),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                        setState(() => _step--);
                      },
                    )
                  : const SizedBox(width: 40),
              Text(
                '${_step + 1} / 3',
                style: AppTextStyles.labelSmall,
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_step + 1) / 3,
              backgroundColor: AppColors.primaryLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(l10n.setupTitle,
              style: AppTextStyles.headingLarge),
          const SizedBox(height: 8),
          Text(l10n.setupSubtitle,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),

          // Name field
          _fieldLabel(l10n.setupName),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: l10n.setupNameHint,
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),

          // Gender
          _fieldLabel(l10n.setupGender),
          const SizedBox(height: 12),
          Row(
            children: [
              _genderCard(
                label: l10n.setupGenderMale,
                icon: Icons.male_rounded,
                isSelected: _gender == Gender.male,
                onTap: () => setState(() => _gender = Gender.male),
              ),
              const SizedBox(width: 12),
              _genderCard(
                label: l10n.setupGenderFemale,
                icon: Icons.female_rounded,
                isSelected: _gender == Gender.female,
                onTap: () => setState(() => _gender = Gender.female),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Age slider
          _fieldLabel('${l10n.setupAge}: $_age'),
          Slider(
            value: _age.toDouble(),
            min: 10,
            max: 90,
            divisions: 80,
            label: '$_age',
            onChanged: (v) => setState(() => _age = v.round()),
          ),
          const SizedBox(height: 24),

          // Weight slider
          _fieldLabel('${l10n.setupWeight}: ${_weight.toStringAsFixed(0)} kg'),
          Slider(
            value: _weight,
            min: 30,
            max: 150,
            divisions: 120,
            label: '${_weight.toStringAsFixed(0)} kg',
            onChanged: (v) => setState(() => _weight = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2(AppLocalizations l10n) {
    final activities = [
      (ActivityLevel.sedentary, l10n.setupActivitySedentary, Icons.chair_rounded, '< 5k passos/dia'),
      (ActivityLevel.light, l10n.setupActivityLight, Icons.directions_walk_rounded, '5-8k passos/dia'),
      (ActivityLevel.moderate, l10n.setupActivityModerate, Icons.directions_run_rounded, '8-12k passos/dia'),
      (ActivityLevel.intense, l10n.setupActivityIntense, Icons.fitness_center_rounded, '> 12k passos/dia'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.setupActivity, style: AppTextStyles.headingLarge),
          const SizedBox(height: 8),
          Text(
            'Escolha o nível que melhor descreve o seu estilo de vida',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          ...activities.map((item) {
            final (level, label, icon, detail) = item;
            final selected = _activity == level;
            return GestureDetector(
              onTap: () => setState(() => _activity = level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primarySurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: selected ? Colors.white : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: selected ? AppColors.primary : AppColors.textPrimary,
                              )),
                          Text(detail,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 22),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          _fieldLabel(l10n.setupWakeTime),
          const SizedBox(height: 8),
          _timePickerTile(
            time: _wakeTime,
            icon: Icons.wb_sunny_rounded,
            label: l10n.setupWakeTime,
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _wakeTime);
              if (t != null) setState(() => _wakeTime = t);
            },
          ),
          const SizedBox(height: 12),
          _timePickerTile(
            time: _sleepTime,
            icon: Icons.nightlight_round,
            label: l10n.setupSleepTime,
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _sleepTime);
              if (t != null) setState(() => _sleepTime = t);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage3(AppLocalizations l10n) {
    final goal = _calculatedGoal;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(l10n.setupGoalTitle, style: AppTextStyles.headingLarge),
          const SizedBox(height: 8),
          Text(l10n.setupGoalSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 40),

          // Goal display
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF5DCCFC), Color(0xFF3AB8F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$goal',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'ml / dia',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Summary cards
          Row(
            children: [
              _summaryCard(
                  icon: Icons.person_outline_rounded,
                  label: 'Peso',
                  value: '${_weight.toStringAsFixed(0)} kg'),
              const SizedBox(width: 12),
              _summaryCard(
                  icon: Icons.cake_rounded,
                  label: 'Idade',
                  value: '$_age anos'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryCard(
                  icon: Icons.fitness_center_rounded,
                  label: 'Atividade',
                  value: _activityLabel(l10n)),
              const SizedBox(width: 12),
              _summaryCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Copos',
                  value: '≈ ${(goal / 250).round()} copos'),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pode ajustar a sua meta a qualquer momento nas configurações.',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 32),
              const SizedBox(height: 8),
              Text(label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timePickerTile({
    required TimeOfDay time,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium),
            const Spacer(),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
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
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodySmall),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
      );

  String _activityLabel(AppLocalizations l10n) {
    switch (_activity) {
      case ActivityLevel.sedentary:
        return l10n.setupActivitySedentary;
      case ActivityLevel.light:
        return l10n.setupActivityLight;
      case ActivityLevel.moderate:
        return l10n.setupActivityModerate;
      case ActivityLevel.intense:
        return l10n.setupActivityIntense;
    }
  }
}

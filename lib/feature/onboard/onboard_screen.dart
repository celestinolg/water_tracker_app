import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared_widget/primary_button/primary_button.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, String>> get _onboardList => [
        {
          'image': 'assets/img/onboard_1.png',
          'titleKey': 'onboard1_title',
          'subtitleKey': 'onboard1_subtitle',
        },
        {
          'image': 'assets/img/onboard_2.png',
          'titleKey': 'onboard2_title',
          'subtitleKey': 'onboard2_subtitle',
        },
        {
          'image': 'assets/img/onboard_3.png',
          'titleKey': 'onboard3_title',
          'subtitleKey': 'onboard3_subtitle',
        },
      ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _onboardList.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/setup');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/setup');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _currentPage == _onboardList.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button or empty
                  _currentPage > 0
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () {
                            _controller.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                        )
                      : const SizedBox(width: 48),

                  // Page indicator dots
                  Row(
                    children: List.generate(
                      _onboardList.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Skip button
                  !isLast
                      ? TextButton(
                          onPressed: _skip,
                          child: Text(
                            l10n.skip,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : const SizedBox(width: 48),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _onboardList.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final item = _onboardList[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration
                          Container(
                            height: 280,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Title
                          Text(
                            l10n.translate(item['titleKey']!),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            l10n.translate(item['subtitleKey']!),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: primaryButton(
                text: isLast ? l10n.start : l10n.next,
                onPressed: _nextPage,
                icon: isLast ? Icons.rocket_launch_rounded : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

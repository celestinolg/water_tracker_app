import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF5DCCFC);
  static const Color primaryDark = Color(0xFF3AB8F0);
  static const Color primaryLight = Color(0xFFB8EDFE);
  static const Color primarySurface = Color(0xFFE8F8FF);

  // Dark blue for headings
  static const Color darkBlue = Color(0xFF004A7C);
  static const Color darkBlueLight = Color(0xFF1A6B9E);

  // Backgrounds
  static const Color background = Color(0xFFF4F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F6FF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF7C7C7C);
  static const Color textHint = Color(0xFFB0B0B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF4ADE80);
  static const Color successGreen = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFF9F1C);
  static const Color error = Color(0xFFEF4444);

  // Drink type colors
  static const Color waterColor = Color(0xFF5DCCFC);
  static const Color teaColor = Color(0xFF96CEB4);
  static const Color juiceColor = Color(0xFFFFB347);
  static const Color coffeeColor = Color(0xFF8B6914);
  static const Color milkColor = Color(0xFFF5F5F5);

  // Chart colors
  static const Color chartBar = Color(0xFF5DCCFC);
  static const Color chartBarGoal = Color(0xFFB8EDFE);
  static const Color chartBarSuccess = Color(0xFF4ADE80);

  // Dividers & borders
  static const Color divider = Color(0xFFE8EEF4);
  static const Color border = Color(0xFFD5E5F0);
  static const Color borderFocus = Color(0xFF5DCCFC);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5DCCFC), Color(0xFF3AB8F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE8F8FF), Color(0xFFF4F8FB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

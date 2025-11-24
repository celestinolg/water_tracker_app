import '../models/user_profile.dart';

class WaterCalculator {
  /// Calculates daily water goal in ml based on user profile
  /// Based on WHO and EFSA guidelines
  static int calculateDailyGoal(UserProfile profile) {
    // Base: 30ml per kg of body weight
    double baseMl = profile.weightKg * 30;

    // Age adjustment
    if (profile.age < 18) {
      baseMl *= 0.9;
    } else if (profile.age > 65) {
      baseMl *= 0.95;
    }

    // Gender adjustment
    if (profile.gender == Gender.female) {
      baseMl *= 0.9; // Women typically need slightly less
    }

    // Activity level adjustment
    switch (profile.activityLevel) {
      case ActivityLevel.sedentary:
        baseMl *= 1.0;
        break;
      case ActivityLevel.light:
        baseMl *= 1.1;
        break;
      case ActivityLevel.moderate:
        baseMl *= 1.2;
        break;
      case ActivityLevel.intense:
        baseMl *= 1.4;
        break;
    }

    // Round to nearest 50ml
    return (baseMl / 50).round() * 50;
  }

  /// Converts ml to oz
  static double mlToOz(int ml) => ml / 29.5735;

  /// Converts oz to ml
  static int ozToMl(double oz) => (oz * 29.5735).round();

  /// Format amount based on unit preference
  static String formatAmount(int ml, String unit) {
    if (unit == 'oz') {
      return '${mlToOz(ml).toStringAsFixed(1)} oz';
    }
    return '$ml ml';
  }

  /// Calculate percentage progress
  static double getProgress(int consumed, int goal) {
    if (goal <= 0) return 0.0;
    return (consumed / goal).clamp(0.0, 1.0);
  }

  /// Get motivational message based on progress
  static String getMotivationalMessage(double progress, String languageCode) {
    if (progress >= 1.0) {
      switch (languageCode) {
        case 'en':
          return '🎉 Goal reached! Amazing!';
        case 'fr':
          return '🎉 Objectif atteint! Bravo!';
        case 'de':
          return '🎉 Ziel erreicht! Fantastisch!';
        default:
          return '🎉 Meta atingida! Excelente!';
      }
    } else if (progress >= 0.75) {
      switch (languageCode) {
        case 'en':
          return '💪 Almost there! Keep going!';
        case 'fr':
          return '💪 Presque là! Continuez!';
        case 'de':
          return '💪 Fast da! Weiter so!';
        default:
          return '💪 Quase lá! Continue assim!';
      }
    } else if (progress >= 0.5) {
      switch (languageCode) {
        case 'en':
          return '👍 Halfway there! Great job!';
        case 'fr':
          return '👍 À mi-chemin! Bon travail!';
        case 'de':
          return '👍 Halbzeit! Gute Arbeit!';
        default:
          return '👍 A meio caminho! Bom trabalho!';
      }
    } else if (progress >= 0.25) {
      switch (languageCode) {
        case 'en':
          return '💧 Good start! Keep drinking!';
        case 'fr':
          return '💧 Bon début! Continuez à boire!';
        case 'de':
          return '💧 Guter Start! Weiter trinken!';
        default:
          return '💧 Bom começo! Continue a beber!';
      }
    } else {
      switch (languageCode) {
        case 'en':
          return '🌊 Let\'s start hydrating!';
        case 'fr':
          return '🌊 Commençons à s\'hydrater!';
        case 'de':
          return '🌊 Fangen wir mit dem Trinken an!';
        default:
          return '🌊 Vamos começar a hidratar!';
      }
    }
  }
}

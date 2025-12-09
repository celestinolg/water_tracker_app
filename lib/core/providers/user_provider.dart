import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/water_calculator.dart';

class UserProvider extends ChangeNotifier {
  final StorageService _storage;

  UserProfile _profile = UserProfile.defaultProfile;

  UserProvider(this._storage);

  UserProfile get profile => _profile;
  bool get isSetupComplete => _profile.isSetupComplete;

  void init() {
    final saved = _storage.getUserProfile();
    if (saved != null) {
      _profile = saved;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _storage.saveUserProfile(profile);

    // Recalculate and save goal if not using custom
    if (!_storage.getUseCustomGoal()) {
      final goal = WaterCalculator.calculateDailyGoal(profile);
      await _storage.setDailyGoalMl(goal);
    }

    notifyListeners();
  }

  Future<void> updateField({
    String? name,
    double? weightKg,
    int? age,
    ActivityLevel? activityLevel,
    Gender? gender,
    int? wakeHour,
    int? sleepHour,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      weightKg: weightKg,
      age: age,
      activityLevel: activityLevel,
      gender: gender,
      wakeHour: wakeHour,
      sleepHour: sleepHour,
    );
    await _storage.saveUserProfile(_profile);
    notifyListeners();
  }

  int get calculatedGoal => WaterCalculator.calculateDailyGoal(_profile);

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home_greeting_morning';
    if (hour < 18) return 'home_greeting_afternoon';
    return 'home_greeting_evening';
  }
}

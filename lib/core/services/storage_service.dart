import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_entry.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _waterEntriesPrefix = 'water_entries_';
  static const String _dailyGoalKey = 'daily_goal_ml';
  static const String _notifEnabledKey = 'notif_enabled';
  static const String _notifIntervalKey = 'notif_interval_hours';
  static const String _languageKey = 'language_code';
  static const String _unitKey = 'unit';
  static const String _customGoalKey = 'custom_goal_ml';
  static const String _useCustomGoalKey = 'use_custom_goal';
  static const String _onboardCompletedKey = 'onboard_completed';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- User Profile ---
  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  UserProfile? getUserProfile() {
    final data = _prefs.getString(_userProfileKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  // --- Onboarding ---
  bool get isOnboardCompleted => _prefs.getBool(_onboardCompletedKey) ?? false;
  Future<void> setOnboardCompleted() async =>
      _prefs.setBool(_onboardCompletedKey, true);

  // --- Water Entries ---
  String _dateKey(DateTime date) =>
      '${_waterEntriesPrefix}${date.year}_${date.month}_${date.day}';

  Future<void> saveWaterEntries(DateTime date, List<WaterEntry> entries) async {
    final key = _dateKey(date);
    final data = entries.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(key, data);
  }

  List<WaterEntry> getWaterEntries(DateTime date) {
    final key = _dateKey(date);
    final data = _prefs.getStringList(key) ?? [];
    return data.map((s) => WaterEntry.fromJson(jsonDecode(s))).toList();
  }

  // Get entries for a range (for stats)
  Map<DateTime, List<WaterEntry>> getEntriesForRange(
      DateTime start, DateTime end) {
    final result = <DateTime, List<WaterEntry>>{};
    var current = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDay)) {
      final entries = getWaterEntries(current);
      result[current] = entries;
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  // --- Goal ---
  Future<void> setDailyGoalMl(int ml) async =>
      _prefs.setInt(_dailyGoalKey, ml);
  int getDailyGoalMl() => _prefs.getInt(_dailyGoalKey) ?? 2000;

  Future<void> setCustomGoalMl(int ml) async =>
      _prefs.setInt(_customGoalKey, ml);
  int getCustomGoalMl() => _prefs.getInt(_customGoalKey) ?? 2000;

  Future<void> setUseCustomGoal(bool value) async =>
      _prefs.setBool(_useCustomGoalKey, value);
  bool getUseCustomGoal() => _prefs.getBool(_useCustomGoalKey) ?? false;

  // --- Notifications ---
  Future<void> setNotifEnabled(bool value) async =>
      _prefs.setBool(_notifEnabledKey, value);
  bool getNotifEnabled() => _prefs.getBool(_notifEnabledKey) ?? true;

  Future<void> setNotifIntervalHours(int hours) async =>
      _prefs.setInt(_notifIntervalKey, hours);
  int getNotifIntervalHours() => _prefs.getInt(_notifIntervalKey) ?? 2;

  // --- Language ---
  Future<void> setLanguageCode(String code) async =>
      _prefs.setString(_languageKey, code);
  String getLanguageCode() => _prefs.getString(_languageKey) ?? 'pt';

  // --- Unit ---
  Future<void> setUnit(String unit) async =>
      _prefs.setString(_unitKey, unit);
  String getUnit() => _prefs.getString(_unitKey) ?? 'ml';

  // --- Reset ---
  Future<void> resetAllData() async {
    final languageCode = getLanguageCode();
    await _prefs.clear();
    await setLanguageCode(languageCode); // preserve language
  }
}

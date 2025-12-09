import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifService;

  late Locale _locale;
  late String _unit;
  late bool _notifEnabled;
  late int _notifIntervalHours;
  late bool _useCustomGoal;
  late int _customGoalMl;

  SettingsProvider(this._storage, this._notifService);

  Locale get locale => _locale;
  String get unit => _unit;
  bool get notifEnabled => _notifEnabled;
  int get notifIntervalHours => _notifIntervalHours;
  bool get useCustomGoal => _useCustomGoal;
  int get customGoalMl => _customGoalMl;

  void init() {
    _locale = Locale(_storage.getLanguageCode());
    _unit = _storage.getUnit();
    _notifEnabled = _storage.getNotifEnabled();
    _notifIntervalHours = _storage.getNotifIntervalHours();
    _useCustomGoal = _storage.getUseCustomGoal();
    _customGoalMl = _storage.getCustomGoalMl();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    await _storage.setLanguageCode(languageCode);
    notifyListeners();
  }

  Future<void> setUnit(String unit) async {
    _unit = unit;
    await _storage.setUnit(unit);
    notifyListeners();
  }

  Future<void> setNotifEnabled(bool value) async {
    _notifEnabled = value;
    await _storage.setNotifEnabled(value);
    if (!value) {
      await _notifService.cancelAllReminders();
    }
    notifyListeners();
  }

  Future<void> setNotifIntervalHours(int hours) async {
    _notifIntervalHours = hours;
    await _storage.setNotifIntervalHours(hours);
    notifyListeners();
  }

  Future<void> setUseCustomGoal(bool value) async {
    _useCustomGoal = value;
    await _storage.setUseCustomGoal(value);
    notifyListeners();
  }

  Future<void> setCustomGoalMl(int ml) async {
    _customGoalMl = ml;
    await _storage.setCustomGoalMl(ml);
    notifyListeners();
  }

  Future<void> scheduleNotifications({
    required int wakeHour,
    required int sleepHour,
    required String title,
    required String body,
  }) async {
    if (_notifEnabled) {
      await _notifService.schedulePeriodicReminders(
        intervalHours: _notifIntervalHours,
        wakeHour: wakeHour,
        sleepHour: sleepHour,
        title: title,
        body: body,
      );
    }
  }

  Future<void> resetAllData() async {
    await _storage.resetAllData();
    init();
    notifyListeners();
  }

  String formatAmount(int ml) {
    if (_unit == 'oz') {
      final oz = ml / 29.5735;
      return '${oz.toStringAsFixed(0)} oz';
    }
    return '$ml ml';
  }
}

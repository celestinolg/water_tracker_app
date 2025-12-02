import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/water_entry.dart';
import '../services/storage_service.dart';

class WaterProvider extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  List<WaterEntry> _todayEntries = [];
  int _dailyGoalMl = 2000;
  DateTime _selectedDate = DateTime.now();
  bool _goalNotified = false;

  WaterProvider(this._storage);

  List<WaterEntry> get todayEntries => List.unmodifiable(_todayEntries);
  int get dailyGoalMl => _dailyGoalMl;
  DateTime get selectedDate => _selectedDate;

  int get totalConsumedMl =>
      _todayEntries.fold(0, (sum, e) => sum + e.effectiveMl);

  int get remainingMl => (_dailyGoalMl - totalConsumedMl).clamp(0, _dailyGoalMl);

  double get progress => (_dailyGoalMl > 0)
      ? (totalConsumedMl / _dailyGoalMl).clamp(0.0, 1.0)
      : 0.0;

  bool get isGoalReached => totalConsumedMl >= _dailyGoalMl;

  void init() {
    _dailyGoalMl = _storage.getDailyGoalMl();
    _loadTodayEntries();
  }

  void _loadTodayEntries() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _todayEntries = _storage.getWaterEntries(_selectedDate);
    notifyListeners();
  }

  Future<void> addEntry(int amountMl, DrinkType drinkType) async {
    final entry = WaterEntry(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      amountMl: amountMl,
      drinkType: drinkType,
    );
    _todayEntries.add(entry);
    await _storage.saveWaterEntries(_selectedDate, _todayEntries);
    notifyListeners();
  }

  Future<WaterEntry?> removeLastEntry() async {
    if (_todayEntries.isEmpty) return null;
    final removed = _todayEntries.removeLast();
    await _storage.saveWaterEntries(_selectedDate, _todayEntries);
    _goalNotified = false;
    notifyListeners();
    return removed;
  }

  Future<void> removeEntry(String id) async {
    _todayEntries.removeWhere((e) => e.id == id);
    await _storage.saveWaterEntries(_selectedDate, _todayEntries);
    _goalNotified = false;
    notifyListeners();
  }

  Future<void> setDailyGoal(int ml) async {
    _dailyGoalMl = ml;
    await _storage.setDailyGoalMl(ml);
    notifyListeners();
  }

  bool checkAndMarkGoalReached() {
    if (isGoalReached && !_goalNotified) {
      _goalNotified = true;
      return true;
    }
    return false;
  }

  // Statistics
  Map<DateTime, int> getWeeklyTotals() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final endDay = DateTime(now.year, now.month, now.day);

    final rangeData = _storage.getEntriesForRange(startDay, endDay);
    return rangeData.map(
      (date, entries) => MapEntry(
        date,
        entries.fold(0, (sum, e) => sum + e.effectiveMl),
      ),
    );
  }

  Map<DateTime, int> getMonthlyTotals() {
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, 1);
    final endDay = DateTime(now.year, now.month, now.day);

    final rangeData = _storage.getEntriesForRange(startDay, endDay);
    return rangeData.map(
      (date, entries) => MapEntry(
        date,
        entries.fold(0, (sum, e) => sum + e.effectiveMl),
      ),
    );
  }

  int getCurrentStreak() {
    int streak = 0;
    var date = DateTime.now();

    while (true) {
      final day = DateTime(date.year, date.month, date.day);
      final entries = _storage.getWaterEntries(day);
      final total = entries.fold(0, (sum, e) => sum + e.effectiveMl);
      if (total >= _dailyGoalMl) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  void refreshToday() {
    _goalNotified = false;
    _loadTodayEntries();
  }
}

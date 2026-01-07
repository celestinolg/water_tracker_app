import 'package:flutter/material.dart';
import 'translations/pt.dart';
import 'translations/en.dart';
import 'translations/fr.dart';
import 'translations/de.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('pt'),
    Locale('en'),
    Locale('fr'),
    Locale('de'),
  ];

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'en':
        return enStrings;
      case 'fr':
        return frStrings;
      case 'de':
        return deStrings;
      case 'pt':
      default:
        return ptStrings;
    }
  }

  String translate(String key) => _strings[key] ?? key;

  // Convenience getters
  // --- General ---
  String get appName => translate('app_name');
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get close => translate('close');
  String get confirm => translate('confirm');
  String get next => translate('next');
  String get back => translate('back');
  String get start => translate('start');
  String get skip => translate('skip');
  String get done => translate('done');
  String get yes => translate('yes');
  String get no => translate('no');

  // --- Splash ---
  String get splashTitle => translate('splash_title');
  String get splashSubtitle => translate('splash_subtitle');

  // --- Onboard ---
  String get onboard1Title => translate('onboard1_title');
  String get onboard1Subtitle => translate('onboard1_subtitle');
  String get onboard2Title => translate('onboard2_title');
  String get onboard2Subtitle => translate('onboard2_subtitle');
  String get onboard3Title => translate('onboard3_title');
  String get onboard3Subtitle => translate('onboard3_subtitle');

  // --- Setup ---
  String get setupTitle => translate('setup_title');
  String get setupSubtitle => translate('setup_subtitle');
  String get setupName => translate('setup_name');
  String get setupNameHint => translate('setup_name_hint');
  String get setupWeight => translate('setup_weight');
  String get setupWeightHint => translate('setup_weight_hint');
  String get setupAge => translate('setup_age');
  String get setupAgeHint => translate('setup_age_hint');
  String get setupActivity => translate('setup_activity');
  String get setupActivitySedentary => translate('setup_activity_sedentary');
  String get setupActivityLight => translate('setup_activity_light');
  String get setupActivityModerate => translate('setup_activity_moderate');
  String get setupActivityIntense => translate('setup_activity_intense');
  String get setupGoalTitle => translate('setup_goal_title');
  String get setupGoalSubtitle => translate('setup_goal_subtitle');
  String get setupFinish => translate('setup_finish');
  String get setupGender => translate('setup_gender');
  String get setupGenderMale => translate('setup_gender_male');
  String get setupGenderFemale => translate('setup_gender_female');
  String get setupWakeTime => translate('setup_wake_time');
  String get setupSleepTime => translate('setup_sleep_time');

  // --- Home ---
  String get homeGreetingMorning => translate('home_greeting_morning');
  String get homeGreetingAfternoon => translate('home_greeting_afternoon');
  String get homeGreetingEvening => translate('home_greeting_evening');
  String get homeGoalLabel => translate('home_goal_label');
  String get homeConsumedLabel => translate('home_consumed_label');
  String get homeRemainingLabel => translate('home_remaining_label');
  String get homeAddWater => translate('home_add_water');
  String get homeHistory => translate('home_history');
  String get homeNoHistory => translate('home_no_history');
  String get homeNextReminder => translate('home_next_reminder');
  String get homeGoalReached => translate('home_goal_reached');
  String get homeGoalReachedMessage => translate('home_goal_reached_message');
  String get homeOf => translate('home_of');
  String get homeQuickAdd => translate('home_quick_add');
  String get homeTodayIntake => translate('home_today_intake');
  String get homeUndoDelete => translate('home_undo_delete');

  // --- Add Water Modal ---
  String get addWaterTitle => translate('add_water_title');
  String get addWaterCustom => translate('add_water_custom');
  String get addWaterDrinkType => translate('add_water_drink_type');
  String get addWaterAmount => translate('add_water_amount');
  String get addWaterAdd => translate('add_water_add');
  String get drinkWater => translate('drink_water');
  String get drinkTea => translate('drink_tea');
  String get drinkJuice => translate('drink_juice');
  String get drinkCoffee => translate('drink_coffee');
  String get drinkMilk => translate('drink_milk');
  String get drinkSports => translate('drink_sports');

  // --- Statistics ---
  String get statsTitle => translate('stats_title');
  String get statsWeekly => translate('stats_weekly');
  String get statsMonthly => translate('stats_monthly');
  String get statsStreak => translate('stats_streak');
  String get statsStreakDays => translate('stats_streak_days');
  String get statsAverage => translate('stats_average');
  String get statsBestDay => translate('stats_best_day');
  String get statsGoalReached => translate('stats_goal_reached');
  String get statsGoalReachedDays => translate('stats_goal_reached_days');
  String get statsTotalWeek => translate('stats_total_week');
  String get statsNoData => translate('stats_no_data');
  String get statsDayMon => translate('stats_day_mon');
  String get statsDayTue => translate('stats_day_tue');
  String get statsDayWed => translate('stats_day_wed');
  String get statsDayThu => translate('stats_day_thu');
  String get statsDayFri => translate('stats_day_fri');
  String get statsDaySat => translate('stats_day_sat');
  String get statsDaySun => translate('stats_day_sun');

  // --- Settings ---
  String get settingsTitle => translate('settings_title');
  String get settingsLanguage => translate('settings_language');
  String get settingsUnit => translate('settings_unit');
  String get settingsUnitMl => translate('settings_unit_ml');
  String get settingsUnitOz => translate('settings_unit_oz');
  String get settingsGoal => translate('settings_goal');
  String get settingsGoalCustom => translate('settings_goal_custom');
  String get settingsGoalAuto => translate('settings_goal_auto');
  String get settingsNotifications => translate('settings_notifications');
  String get settingsNotifEnabled => translate('settings_notif_enabled');
  String get settingsNotifInterval => translate('settings_notif_interval');
  String get settingsNotifStart => translate('settings_notif_start');
  String get settingsNotifEnd => translate('settings_notif_end');
  String get settingsAccount => translate('settings_account');
  String get settingsAbout => translate('settings_about');
  String get settingsVersion => translate('settings_version');
  String get settingsReset => translate('settings_reset');
  String get settingsResetConfirm => translate('settings_reset_confirm');

  // --- Profile ---
  String get profileTitle => translate('profile_title');
  String get profileEditProfile => translate('profile_edit_profile');
  String get profileDailyGoal => translate('profile_daily_goal');
  String get profileWeight => translate('profile_weight');
  String get profileAge => translate('profile_age');
  String get profileActivity => translate('profile_activity');
  String get profileTotalDays => translate('profile_total_days');
  String get profileBestStreak => translate('profile_best_streak');

  // --- Notifications ---
  String get notifReminderTitle => translate('notif_reminder_title');
  String get notifReminderBody => translate('notif_reminder_body');
  String get notifGoalTitle => translate('notif_goal_title');
  String get notifGoalBody => translate('notif_goal_body');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['pt', 'en', 'fr', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

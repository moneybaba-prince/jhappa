
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  static const String _keyOnboarded = 'onboarded';
  static const String _keyLanguage = 'selected_language';
  static const String _keyMantra = 'selected_mantra';
  static const String _keyCustomMantras = 'custom_mantras';
  static const String _keyCurrentBead = 'current_bead';
  static const String _keyCompletedMalas = 'completed_malas';
  static const String _keyTodayTotalBeads = 'today_total_beads';
  static const String _keyTodayDate = 'today_date';
  static const String _keyDailyCountHistory = 'daily_count_history';
  static const String _keyTotalCount = 'total_count';
  static const String _keyVowTarget = 'vow_target_malas';
  static const String _keyDarkChanting = 'dark_chanting_mode';
  static const String _keyBackgroundColor = 'background_color';
  static const String _keyBackgroundImagePath = 'background_image_path';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _resetTodayIfNeeded();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _resetTodayIfNeeded() async {
    final today = _dateKey(DateTime.now());
    if (_prefs.getString(_keyTodayDate) == today) return;

    await _prefs.setInt(_keyTodayTotalBeads, 0);
    await _prefs.setString(_keyTodayDate, today);
  }

  // Onboarding & Language
  bool get onboarded => _prefs.getBool(_keyOnboarded) ?? false;

  Future<void> setOnboarded(bool value) async {
    await _prefs.setBool(_keyOnboarded, value);
  }

  String get selectedLanguage =>
      _prefs.getString(_keyLanguage) ?? 'hi';

  Future<void> setSelectedLanguage(String lang) async {
    await _prefs.setString(_keyLanguage, lang);
  }

  Future<void> completeOnboarding({
    required String language,
    required String mantra,
  }) async {
    await setSelectedLanguage(language);
    await setSelectedMantra(mantra);
    await setOnboarded(true);
  }

  // Active Mantra & Custom Mantras
  String get selectedMantra => _prefs.getString(_keyMantra) ?? 'राम';

  Future<void> setSelectedMantra(String mantra) async {
    await _prefs.setString(_keyMantra, mantra);
  }

  List<String> get customMantras =>
      _prefs.getStringList(_keyCustomMantras) ?? [];

  Future<void> addCustomMantra(String newMantra) async {
    final current = customMantras;

    if (!current.contains(newMantra)) {
      current.add(newMantra);
      await _prefs.setStringList(_keyCustomMantras, current);
    }
  }

  // Counters
  int get currentBead => _prefs.getInt(_keyCurrentBead) ?? 0;

  int get completedMalas => _prefs.getInt(_keyCompletedMalas) ?? 0;

  int get todayTotalBeads =>
      _prefs.getInt(_keyTodayTotalBeads) ?? 0;

  Future<int> getTodayTotalBeads() async {
    await _resetTodayIfNeeded();
    return todayTotalBeads;
  }

  // Compatibility getters used by tests and counter UI.
  int get totalCount => _prefs.getInt(_keyTotalCount) ?? 0;

  int get todayCount => todayTotalBeads;

  Map<String, int> get dailyCountHistory {
    final encoded = _prefs.getString(_keyDailyCountHistory);
    if (encoded == null) return {};

    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Daily count history must be a JSON object.');
    }

    final history = <String, int>{};
    for (final entry in decoded.entries) {
      if (entry.value is! int || (entry.value as int) < 0) {
        throw FormatException(
          'Daily count history for ${entry.key} must be a non-negative integer.',
        );
      }
      history[entry.key] = entry.value as int;
    }
    return history;
  }

  // Vow Target
  int get vowTargetMalas => _prefs.getInt(_keyVowTarget) ?? 16;

  Future<void> setVowTargetMalas(int target) async {
    await _prefs.setInt(_keyVowTarget, target);
  }

  // Save counter state.
  // Call this whenever counting or undoing a bead.
  Future<void> saveCountState({
    required int currentBead,
    required int completedMalas,
    required int todayTotalBeads,
    required int totalCount,
  }) async {
    await _resetTodayIfNeeded();
    await _prefs.setInt(_keyCurrentBead, currentBead);
    await _prefs.setInt(_keyCompletedMalas, completedMalas);
    await _prefs.setInt(_keyTodayTotalBeads, todayTotalBeads);
    await _prefs.setInt(_keyTotalCount, totalCount);

    final history = dailyCountHistory;
    history[_dateKey(DateTime.now())] = todayTotalBeads;
    await _prefs.setString(_keyDailyCountHistory, jsonEncode(history));
  }

  // Theme
  bool get isDarkChantingMode =>
      _prefs.getBool(_keyDarkChanting) ?? true;

  Future<void> setDarkChantingMode(bool value) async {
    await _prefs.setBool(_keyDarkChanting, value);
  }

  int get backgroundColorValue =>
      _prefs.getInt(_keyBackgroundColor) ?? 0xFF0D0D0D;

  Future<void> setBackgroundColorValue(int value) async {
    await _prefs.setInt(_keyBackgroundColor, value);
    await _prefs.remove(_keyBackgroundImagePath);
  }

  String? get backgroundImagePath =>
      _prefs.getString(_keyBackgroundImagePath);

  Future<void> setBackgroundImagePath(String? path) async {
    if (path == null) {
      await _prefs.remove(_keyBackgroundImagePath);
      return;
    }
    await _prefs.setString(_keyBackgroundImagePath, path);
  }
}
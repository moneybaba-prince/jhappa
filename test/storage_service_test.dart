import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaapa/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resets the daily count when the stored date is not today', () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year.toString().padLeft(4, '0')}-'
        '${yesterday.month.toString().padLeft(2, '0')}-'
        '${yesterday.day.toString().padLeft(2, '0')}';

    SharedPreferences.setMockInitialValues({
      'today_date': yesterdayKey,
      'today_total_beads': 23,
      'total_count': 131,
      'current_bead': 131,
      'completed_malas': 1,
      'daily_count_history': jsonEncode({yesterdayKey: 45}),
    });

    final storage = StorageService();
    await storage.init();

    expect(storage.todayTotalBeads, 0);
    expect(storage.totalCount, 131);
    expect(storage.currentBead, 131);
    expect(storage.completedMalas, 1);
    expect(storage.dailyCountHistory[yesterdayKey], 45);

    await storage.saveCountState(
      currentBead: 132,
      completedMalas: 1,
      todayTotalBeads: 1,
      totalCount: 132,
    );

    expect(storage.dailyCountHistory[yesterdayKey], 45);
    expect(storage.dailyCountHistory.values.toSet(), {1, 45});
  });

  test('keeps the daily bead total when storage is initialized again today',
      () async {
    SharedPreferences.setMockInitialValues({});

    final firstSession = StorageService();
    await firstSession.init();
    await firstSession.saveCountState(
      currentBead: 3,
      completedMalas: 0,
      todayTotalBeads: 3,
      totalCount: 3,
    );

    final secondSession = StorageService();
    await secondSession.init();

    expect(secondSession.todayTotalBeads, 3);
    expect(secondSession.dailyCountHistory.values.single, 3);
  });

  test('stores a selected background image and clears it when a color is set',
      () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    await storage.setBackgroundImagePath('/images/meditation.jpg');
    expect(storage.backgroundImagePath, '/images/meditation.jpg');

    await storage.setBackgroundColorValue(0xFF142238);
    expect(storage.backgroundImagePath, isNull);
    expect(storage.backgroundColorValue, 0xFF142238);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaapa/main.dart';
import 'package:jaapa/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding opens the counter and counting can be undone', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    await tester.pumpWidget(JaapaApp(storage: storage));
    await tester.pumpAndSettle();

    expect(
      find.text('जापा में आपका स्वागत है\nWelcome to Jaapa'),
      findsOneWidget,
    );
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.text('श्री राम जय राम जय जय राम'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('start-counting-button')),
      200,
    );
    await tester.tap(find.byKey(const ValueKey('start-counting-button')));
    await tester.pumpAndSettle();

    expect(find.text('CURRENT MALA'), findsOneWidget);
    await tester.tap(find.text('Tap anywhere to count'));
    await tester.pumpAndSettle();
    expect(storage.totalCount, 1);
    expect(storage.todayCount, 1);

    await tester.tap(find.byKey(const ValueKey('daily-history-button')));
    await tester.pumpAndSettle();
    expect(find.text('Daily history'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo last bead'));
    await tester.pumpAndSettle();
    expect(storage.totalCount, 0);
    expect(storage.todayCount, 0);
    expect(storage.dailyCountHistory.values.single, 0);

    expect(storage.isDarkChantingMode, isTrue);
    await tester.tap(find.byTooltip('Chanting dark mode'));
    await tester.pumpAndSettle();
    final counterScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(storage.isDarkChantingMode, isFalse);
    expect(counterScaffold.backgroundColor, isNull);

    await tester.tap(find.byTooltip('Chanting dark mode'));
    await tester.pumpAndSettle();
    final darkCounterScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(storage.isDarkChantingMode, isTrue);
    expect(darkCounterScaffold.backgroundColor, const Color(0xFF0D0D0D));

    await tester
        .tap(find.byKey(const ValueKey('choose-background-color-button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('choose-background-image')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('background-color-Saffron')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('background-color-Saffron')));
    await tester.pumpAndSettle();
    expect(storage.backgroundColorValue, 0xFFFF9933);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFFFF9933),
    );

    await tester
        .tap(find.byKey(const ValueKey('choose-background-color-button')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('background-color-Red')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('background-color-Red')));
    await tester.pumpAndSettle();
    expect(storage.backgroundColorValue, 0xFFC62828);

    await tester
        .tap(find.byKey(const ValueKey('choose-background-color-button')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey('background-color-Midnight blue')));
    await tester.pumpAndSettle();
    final coloredCounterScaffold =
        tester.widget<Scaffold>(find.byType(Scaffold));
    expect(coloredCounterScaffold.backgroundColor, const Color(0xFF142238));
    expect(storage.backgroundColorValue, 0xFF142238);

    await tester.tap(find.byKey(const ValueKey('back-to-setup-button')));
    await tester.pumpAndSettle();
    expect(
      find.text('जापा में आपका स्वागत है\nWelcome to Jaapa'),
      findsOneWidget,
    );
    expect(storage.selectedLanguage, 'en');
    expect(storage.selectedMantra, 'श्री राम जय राम जय जय राम');
    final setupScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(setupScaffold.backgroundColor, const Color(0xFF142238));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('start-counting-button')),
      200,
    );
    await tester.tap(find.byKey(const ValueKey('start-counting-button')));
    await tester.pumpAndSettle();
    expect(find.text('CURRENT MALA'), findsOneWidget);
  });
}

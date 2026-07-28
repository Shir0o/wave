import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wave/models/drink_entry.dart';
import 'package:wave/screens/smart_log_screen.dart';
import 'package:wave/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createSmartLogScreen(AppState state) {
    return ChangeNotifierProvider<AppState>.value(
      value: state,
      child: const MaterialApp(home: SmartLogScreen()),
    );
  }

  group('SmartLogScreen Widget Tests', () {
    testWidgets('renders Last session card when entries exist', (
      WidgetTester tester,
    ) async {
      final state = AppState();
      await tester.pump(const Duration(milliseconds: 100));

      // Clear default mock entries and add a session
      state.entries.clear();
      final now = DateTime.now();
      state.addDrinkEntry(
        DrinkEntry(
          id: 'test_1',
          name: 'Iced Latte',
          icon: 'local_cafe',
          oz: 16.0,
          hydration: 12.8,
          time: now,
          source: 'AI log',
          batch: 1,
        ),
      );
      state.addDrinkEntry(
        DrinkEntry(
          id: 'test_2',
          name: 'Water',
          icon: 'water_drop',
          oz: 8.0,
          hydration: 8.0,
          time: now,
          source: 'AI log',
          batch: 1,
        ),
      );

      await tester.pumpWidget(createSmartLogScreen(state));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Last session'), findsOneWidget);
      expect(find.text('Iced Latte'), findsOneWidget);
      expect(find.textContaining('Add the same again'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('tapping Add the same again repeats previous batch', (
      WidgetTester tester,
    ) async {
      final state = AppState();
      await tester.pump(const Duration(milliseconds: 100));

      state.entries.clear();
      final now = DateTime.now();
      state.addDrinkEntry(
        DrinkEntry(
          id: 'test_1',
          name: 'Iced Latte',
          icon: 'local_cafe',
          oz: 16.0,
          hydration: 12.8,
          time: now,
          source: 'AI log',
          batch: 1,
        ),
      );

      await tester.pumpWidget(createSmartLogScreen(state));
      await tester.pump(const Duration(milliseconds: 100));

      final repeatBtn = find.textContaining('Add the same again');
      expect(repeatBtn, findsOneWidget);
      await tester.tap(repeatBtn);
      await tester.pump(const Duration(milliseconds: 100));

      expect(state.entries.length, 2);
      expect(state.entries.last.source, 'Repeat');
      await tester.pump(const Duration(seconds: 2));
    });
  });
}

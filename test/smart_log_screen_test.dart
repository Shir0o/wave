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

    testWidgets('tapping back button navigates home and clears AI state', (
      WidgetTester tester,
    ) async {
      final state = AppState();
      await tester.pump(const Duration(milliseconds: 100));
      state.setAiText('coffee');

      await tester.pumpWidget(createSmartLogScreen(state));
      await tester.pump(const Duration(milliseconds: 100));

      final backBtn = find.byIcon(Icons.arrow_back_rounded);
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pump(const Duration(milliseconds: 100));

      expect(state.currentScreen, 'home');
      expect(state.aiText, '');
    });

    testWidgets(
      'entering text in input box updates AI result and renders results card',
      (WidgetTester tester) async {
        final state = AppState();
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(createSmartLogScreen(state));
        await tester.pump(const Duration(milliseconds: 100));

        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);
        await tester.enterText(textField, 'two glasses of water');
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text("Here's what I got"), findsOneWidget);
        final logAllBtn = find.text('Log all drinks');
        expect(logAllBtn, findsOneWidget);

        // Tap Clear
        final clearBtn = find.text('Clear');
        await tester.ensureVisible(clearBtn);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(clearBtn);
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text("Here's what I got"), findsNothing);
      },
    );

    testWidgets('tapping sample chips sets AI text', (
      WidgetTester tester,
    ) async {
      final state = AppState();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createSmartLogScreen(state));
      await tester.pump(const Duration(milliseconds: 100));

      final chip = find.text('a venti oat latte');
      expect(chip, findsOneWidget);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump(const Duration(milliseconds: 100));

      expect(state.aiText, 'a venti oat latte');
      expect(find.text("Here's what I got"), findsOneWidget);
    });

    testWidgets(
      'triggering mic voice simulation shows listening animation then sets result',
      (WidgetTester tester) async {
        final state = AppState();
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(createSmartLogScreen(state));
        await tester.pump(const Duration(milliseconds: 100));

        final micBtn = find.byIcon(Icons.mic_rounded);
        expect(micBtn, findsOneWidget);
        await tester.tap(micBtn);
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Listening...'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 1200));
        expect(state.aiText, 'two glasses of water and a cold brew');
      },
    );

    testWidgets('triggering photo scan sets random photo sample', (
      WidgetTester tester,
    ) async {
      final state = AppState();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createSmartLogScreen(state));
      await tester.pump(const Duration(milliseconds: 100));

      final photoBtn = find.byIcon(Icons.photo_camera_rounded);
      expect(photoBtn, findsOneWidget);
      await tester.tap(photoBtn);
      await tester.pump(const Duration(milliseconds: 100));

      expect(state.aiText, isNotEmpty);
    });

    testWidgets(
      'tapping arrow send button and Log all drinks confirms AI log',
      (WidgetTester tester) async {
        final state = AppState();
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(createSmartLogScreen(state));
        await tester.pump(const Duration(milliseconds: 100));

        final textField = find.byType(TextField);
        await tester.enterText(textField, '500 ml sparkling water');
        await tester.pump(const Duration(milliseconds: 100));

        final sendBtn = find.byIcon(Icons.arrow_upward_rounded);
        await tester.tap(sendBtn);
        await tester.pump(const Duration(milliseconds: 100));

        final logAllBtn = find.text('Log all drinks');
        expect(logAllBtn, findsOneWidget);
        await tester.ensureVisible(logAllBtn);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(logAllBtn);
        await tester.pump(const Duration(milliseconds: 100));

        expect(state.currentScreen, 'home');
        expect(state.entries.any((e) => e.name == 'Sparkling water'), true);
        await tester.pump(const Duration(seconds: 2));
      },
    );

    testWidgets(
      'tapping single item chip in Last Session card calls repeatOne',
      (WidgetTester tester) async {
        final state = AppState();
        await tester.pump(const Duration(milliseconds: 100));

        state.entries.clear();
        state.addDrinkEntry(
          DrinkEntry(
            id: 'test_single',
            name: 'Matcha',
            icon: 'emoji_food_beverage',
            oz: 12.0,
            hydration: 10.8,
            time: DateTime.now(),
            source: 'Quick add',
            batch: 1,
          ),
        );

        await tester.pumpWidget(createSmartLogScreen(state));
        await tester.pump(const Duration(milliseconds: 100));

        final itemChip = find.text('Matcha');
        expect(itemChip, findsOneWidget);
        await tester.tap(itemChip);
        await tester.pump(const Duration(milliseconds: 100));

        expect(state.entries.length, 2);
        expect(state.entries.last.name, 'Matcha');
        await tester.pump(const Duration(seconds: 2));
      },
    );
  });
}

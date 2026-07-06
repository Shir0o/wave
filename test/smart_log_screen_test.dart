import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/screens/smart_log_screen.dart';
import 'package:wave/state/app_state.dart';
import 'mock_health.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockPlatformChannels();

  group('SmartLogScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'Renders SmartLogScreen, accepts input, triggers sims, and logs',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final state = AppState();

        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: const MaterialApp(home: SmartLogScreen()),
          ),
        );

        // Verify header texts
        expect(find.text('Smart log'), findsOneWidget);
        expect(find.text('Just describe your drink'), findsOneWidget);

        // Verify no result box initially
        expect(find.text("Here's what I got"), findsNothing);

        // Enter text into the textfield
        final textfieldFinder = find.byType(TextField);
        expect(textfieldFinder, findsOneWidget);
        await tester.enterText(textfieldFinder, '16 oz water');
        await tester.pump();

        // Verify state was updated and result box appears
        expect(state.aiText, '16 oz water');
        expect(find.text("Here's what I got"), findsOneWidget);
        expect(find.text('Water'), findsOneWidget);
        expect(find.text('16 oz · 100% hydration'), findsOneWidget);

        // Tap on a chip suggestion (e.g. 'herbal tea mug')
        final chipFinder = find.text('herbal tea mug');
        expect(chipFinder, findsOneWidget);
        await tester.tap(chipFinder);
        await tester.pump();

        expect(state.aiText, 'herbal tea mug');
        expect(find.text('Tea'), findsOneWidget);

        // Tap the clear button in results
        final clearBtnFinder = find.text('Clear');
        expect(clearBtnFinder, findsOneWidget);
        await tester.tap(clearBtnFinder);
        await tester.pump();

        expect(state.aiText, '');
        expect(find.text("Here's what I got"), findsNothing);

        // Tap photo camera button
        final cameraFinder = find.byIcon(Icons.photo_camera_rounded);
        expect(cameraFinder, findsOneWidget);
        await tester.tap(cameraFinder);
        await tester.pump();
        expect(state.aiText, isNotEmpty);

        // Reset AI text
        state.clearAi();
        await tester.pump();

        // Tap voice mic button
        final micFinder = find.byIcon(Icons.mic_rounded);
        expect(micFinder, findsOneWidget);
        await tester.tap(micFinder);
        // Pump frame to trigger state.aiListening
        await tester.pump();
        expect(state.aiListening, true);
        expect(find.text('Listening...'), findsOneWidget);

        // Wait for delay to complete voice simulation
        await tester.pump(const Duration(milliseconds: 1500));
        expect(state.aiListening, false);
        expect(state.aiText, 'two glasses of water and a cold brew');

        // Click "Log all drinks"
        final logBtnFinder = find.text('Log all drinks');
        expect(logBtnFinder, findsOneWidget);
        await tester.tap(logBtnFinder);

        // confirmAiLog triggers showToast with a 1900ms timer
        // We must pump 2 seconds to clear the pending timer.
        await tester.pump(const Duration(seconds: 2));

        expect(state.currentScreen, 'home');
      },
    );

    testWidgets('Header back button navigates home and clears AI state', (
      WidgetTester tester,
    ) async {
      final state = AppState();
      state.navigateTo('log');
      state.setAiText('12 oz soda');

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: SmartLogScreen()),
        ),
      );

      final backBtnFinder = find.byIcon(Icons.arrow_back_rounded);
      expect(backBtnFinder, findsOneWidget);
      await tester.tap(backBtnFinder);
      await tester.pump();

      expect(state.currentScreen, 'home');
      expect(state.aiText, '');
    });
  });
}

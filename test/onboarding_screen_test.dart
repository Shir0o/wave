import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/screens/onboarding_screen.dart';
import 'package:wave/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Renders onboarding screen, allows goal adjustments, and finishes', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Verify page text
      expect(find.text('Ride your\nhydration wave.'), findsOneWidget);
      expect(find.text('DAILY GOAL'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);

      // Find the add (plus) button and click it
      final plusFinder = find.byIcon(Icons.add);
      expect(plusFinder, findsOneWidget);
      await tester.tap(plusFinder);
      await tester.pump();
      
      expect(state.onbGoal, 108.0);
      expect(find.text('108'), findsOneWidget);

      // Find the remove (minus) button and click it
      final minusFinder = find.byIcon(Icons.remove);
      expect(minusFinder, findsOneWidget);
      await tester.tap(minusFinder);
      await tester.pump();

      expect(state.onbGoal, 100.0);
      expect(find.text('100'), findsOneWidget);

      // Verify switch and toggle it
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
      expect(state.onbConnect, false);

      // Find 'Dive in' and tap it
      final diveInFinder = find.text('Dive in');
      expect(diveInFinder, findsOneWidget);
      await tester.tap(diveInFinder);
      
      // finishOnboarding triggers showToast with a 1900ms timer
      // We must pump 2 seconds to clear the pending timer.
      await tester.pump(const Duration(seconds: 2));

      expect(state.currentScreen, 'home');
      expect(state.goalOz, 100.0);
      expect(state.healthConnectConnected, false);
    });
  });
}

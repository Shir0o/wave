import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/main.dart';
import 'package:wave/state/app_state.dart';

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WaveApp Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('WaveApp full flow integration test', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
            theme: ThemeData(
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  for (var platform in TargetPlatform.values)
                    platform: const NoTransitionsBuilder(),
                },
              ),
            ),
            home: const MainNavigationWrapper(),
          ),
        ),
      );

      // Settle initial loading frames
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify Home Screen elements are found
      expect(find.text("Today's drinks"), findsOneWidget);
      expect(find.text('Glass'), findsOneWidget);
      expect(find.text('Bottle'), findsOneWidget);
      expect(find.text('Coffee'), findsNWidgets(2));

      // 2. Toggle theme directly to verify state and UI updates
      state.toggleTheme();
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.isDarkTheme, true);

      // Toggle back to light theme
      state.toggleTheme();
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.isDarkTheme, false);

      // 3. Perform Quick Add and check toast notification
      final glassFinder = find.text('Glass');
      await tester.tap(glassFinder);
      await tester.pump(const Duration(milliseconds: 200));

      // Toast message should show +8 oz Water
      expect(state.toastMessage, '+8 oz Water');
      expect(find.text('+8 oz Water'), findsOneWidget);

      // 4. Navigate using bottom navigation (e.g. to Reminders screen)
      final remindersTabFinder = find.text('Reminders');
      expect(remindersTabFinder, findsOneWidget);
      await tester.tap(remindersTabFinder);
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.currentScreen, 'reminders');
      expect(find.text('Next splash at 8:00 AM'), findsOneWidget);

      // 5. Navigate to Trends screen
      final trendsTabFinder = find.text('Trends');
      expect(trendsTabFinder, findsOneWidget);
      await tester.tap(trendsTabFinder);
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.currentScreen, 'stats');
      expect(find.text('STREAK'), findsOneWidget);

      // 6. Navigate to Sync screen
      final syncTabFinder = find.text('Sync');
      expect(syncTabFinder, findsOneWidget);
      await tester.tap(syncTabFinder);
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.currentScreen, 'sync');
      expect(find.text('Health Connect'), findsNWidgets(2));

      // 7. Click central FAB to open Smart Log screen
      final fabFinder = find.byIcon(Icons.auto_awesome_rounded);
      expect(fabFinder, findsOneWidget);
      await tester.tap(fabFinder);
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.currentScreen, 'log');
      expect(find.text('Just describe your drink'), findsOneWidget);

      // 8. Go back to Home
      final backBtnFinder = find.byIcon(Icons.arrow_back_rounded);
      expect(backBtnFinder, findsOneWidget);
      await tester.tap(backBtnFinder);
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.currentScreen, 'home');

      // 9. Remove a drink item by dismissing it
      final initialLength = state.entries.length;
      final dismissibleFinder = find.byType(Dismissible).first;
      expect(dismissibleFinder, findsOneWidget);

      // Swipe left on dismissible
      await tester.drag(dismissibleFinder, const Offset(-500.0, 0.0));

      // Pump multiple frames of 100ms to let the dismiss animation and the toast timer fully resolve.
      // Total elapsed duration = 40 * 100ms = 4.0 seconds, which easily covers the 300ms swipe/resize + 1.9s toast.
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(state.entries.length, initialLength - 1);
    });

    testWidgets(
      'WaveApp handles onboard screen correctly in main navigation shell',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final state = AppState();
        state.navigateTo('onboard');

        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: MaterialApp(
              theme: ThemeData(
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    for (var platform in TargetPlatform.values)
                      platform: const NoTransitionsBuilder(),
                  },
                ),
              ),
              home: const MainNavigationWrapper(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Ride your\nhydration wave.'), findsOneWidget);
      },
    );
  });
}

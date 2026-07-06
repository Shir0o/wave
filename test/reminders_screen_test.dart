import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/screens/reminders_screen.dart';
import 'package:wave/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemindersScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'Renders RemindersScreen, toggles settings and scheduled rows',
      (WidgetTester tester) async {
        final state = AppState();

        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: const MaterialApp(home: RemindersScreen()),
          ),
        );

        // Verify title and headers are present
        expect(find.text('Reminders'), findsOneWidget);
        expect(find.text('Adaptive reminders'), findsOneWidget);
        expect(find.text('Active hours'), findsOneWidget);
        expect(find.text('SCHEDULED TIMES'), findsOneWidget);

        // Verify initial interval
        expect(find.text('90 min'), findsOneWidget);

        // Find the add (plus) button to increment interval
        final addIconFinder = find.byIcon(Icons.add);
        expect(addIconFinder, findsOneWidget);
        await tester.tap(addIconFinder);
        await tester.pump();
        expect(state.reminderInterval, 105);
        expect(find.text('105 min'), findsOneWidget);

        // Find the remove (minus) button to decrement interval
        final removeIconFinder = find.byIcon(Icons.remove);
        expect(removeIconFinder, findsOneWidget);
        await tester.tap(removeIconFinder);
        await tester.pump();
        expect(state.reminderInterval, 90);
        expect(find.text('90 min'), findsOneWidget);

        // Toggle adaptive reminders switch
        final switches = find.byType(Switch);
        expect(switches, findsAtLeastNWidgets(2));

        // Tap the first switch (adaptive reminders)
        await tester.tap(switches.first);
        await tester.pump();
        expect(state.adaptiveReminders, false);

        // Toggle the first scheduled reminder row switch
        final initialSecondRowEnabled = state.reminders[0]['enabled'];
        await tester.tap(switches.at(1));
        await tester.pump();
        expect(state.reminders[0]['enabled'], !initialSecondRowEnabled);
      },
    );

    testWidgets('Renders properly when no active reminders', (
      WidgetTester tester,
    ) async {
      final state = AppState();
      // Wait for async constructor load
      await tester.pump();
      // disable all reminders
      for (int i = 0; i < state.reminders.length; i++) {
        if (state.reminders[i]['enabled'] == true) {
          state.toggleReminderRow(i);
        }
      }

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: RemindersScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Next splash at None'), findsOneWidget);
    });
  });
}

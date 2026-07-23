import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/models/drink_entry.dart';
import 'package:wave/state/app_state.dart';
import 'mock_health.dart';

void main() {
  // Ensure Flutter binding is initialized for SharedPreferences mock
  TestWidgetsFlutterBinding.ensureInitialized();
  mockPlatformChannels();

  group('AppState Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'initialization with default settings when no preferences exist',
      () async {
        final state = AppState();
        // Wait for preferences to load asynchronously
        await Future.delayed(const Duration(milliseconds: 100));

        expect(state.currentScreen, 'home');
        expect(state.goalOz, 100.0);
        expect(state.isDarkTheme, false);
        expect(state.unit, 'oz');
        expect(state.entries.length, 7); // mock default entries
        expect(state.adaptiveReminders, true);
        expect(state.reminderInterval, 90);
        expect(state.healthConnectConnected, true);
        expect(state.lastSyncStr, 'just now');
        expect(state.permissions.length, 5);
        expect(state.aiText, '');
        expect(state.aiResult, isNull);
        expect(state.aiListening, false);
        expect(state.onbGoal, 100.0);
        expect(state.onbConnect, true);
        expect(state.toastMessage, isNull);
      },
    );

    test('initialization loads settings from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'goalOz': 120.0,
        'isDarkTheme': true,
        'unit': 'ml',
        'adaptiveReminders': false,
        'reminderInterval': 60,
        'healthConnectConnected': false,
        'entries':
            '[{"id":"10","name":"Apple Juice","icon":"local_bar","oz":10.0,"hydration":8.5,"time":"2026-07-06T10:00:00Z","source":"AI"}]',
        'reminders': '[{"time":"10:00 AM","enabled":true}]',
        'permissions': '[{"label":"Test","desc":"Desc","enabled":false}]',
      });

      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(state.goalOz, 120.0);
      expect(state.isDarkTheme, true);
      expect(state.unit, 'ml');
      expect(state.adaptiveReminders, false);
      expect(state.reminderInterval, 60);
      expect(state.healthConnectConnected, false);
      expect(state.entries.length, 1);
      expect(state.entries[0].name, 'Apple Juice');
      expect(state.reminders.length, 1);
      expect(state.reminders[0]['time'], '10:00 AM');
      expect(state.permissions.length, 1);
      expect(state.permissions[0]['enabled'], false);
    });

    test('navigateTo changes current screen', () {
      final state = AppState();
      state.navigateTo('settings');
      expect(state.currentScreen, 'settings');

      state.navigateTo('onboard');
      expect(state.currentScreen, 'onboard');
      expect(state.onbGoal, state.goalOz);
      expect(state.onbConnect, state.healthConnectConnected);
    });

    test('showToast sets and clears toastMessage after delay', () async {
      final state = AppState();
      state.showToast('Test Toast');
      expect(state.toastMessage, 'Test Toast');

      // Toast is cleared after 1900ms
      await Future.delayed(const Duration(milliseconds: 2000));
      expect(state.toastMessage, isNull);
    });

    test('toggleTheme updates theme setting and saves to prefs', () async {
      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(state.isDarkTheme, false);
      state.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(state.isDarkTheme, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkTheme'), true);
    });

    test('setUnit updates unit setting and saves to prefs', () async {
      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(state.unit, 'oz');
      state.setUnit('ml');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(state.unit, 'ml');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('unit'), 'ml');
    });

    test('addDrinkEntry adds entry and shows toast', () {
      final state = AppState();
      final entry = DrinkEntry(
        id: 'new-id',
        name: 'Soda',
        icon: 'local_drink',
        oz: 12.0,
        hydration: 9.0,
        time: DateTime.now(),
        source: 'Manual',
      );

      state.addDrinkEntry(entry);
      expect(state.entries.contains(entry), true);
      expect(state.toastMessage, '+12 oz Soda');
    });

    test('quickAdd methods add corresponding drink entries', () {
      final state = AppState();
      final initialLength = state.entries.length;

      state.quickAddGlass();
      expect(state.entries.length, initialLength + 1);
      expect(state.entries.last.name, 'Water');
      expect(state.entries.last.oz, 8.0);

      state.quickAddBottle();
      expect(state.entries.length, initialLength + 2);
      expect(state.entries.last.name, 'Water');
      expect(state.entries.last.oz, 16.0);

      state.quickAddCoffee();
      expect(state.entries.length, initialLength + 3);
      expect(state.entries.last.name, 'Coffee');
      expect(state.entries.last.oz, 12.0);
    });

    test('removeEntry removes entry by ID', () {
      final state = AppState();
      final entry = DrinkEntry(
        id: 'temp-id',
        name: 'Water',
        icon: 'water_drop',
        oz: 8.0,
        hydration: 8.0,
        time: DateTime.now(),
        source: 'Quick add',
      );
      state.addDrinkEntry(entry);
      expect(state.entries.any((e) => e.id == 'temp-id'), true);

      state.removeEntry('temp-id');
      expect(state.entries.any((e) => e.id == 'temp-id'), false);
    });

    test('setAiText parses input and updates state', () {
      final state = AppState();
      state.setAiText('16 oz cold brew');
      expect(state.aiText, '16 oz cold brew');
      expect(state.aiResult, isNotNull);
      expect(state.aiResult!.items[0].name, 'Coffee');

      state.setAiText('');
      expect(state.aiText, '');
      expect(state.aiResult, isNull);
    });

    test('clearAi resets AI states', () {
      final state = AppState();
      state.setAiText('16 oz cold brew');
      state.clearAi();
      expect(state.aiText, '');
      expect(state.aiResult, isNull);
    });

    test('triggerVoiceSim updates listening and sets parsed results', () async {
      final state = AppState();
      state.triggerVoiceSim();
      expect(state.aiListening, true);

      await Future.delayed(const Duration(milliseconds: 1200));
      expect(state.aiListening, false);
      expect(state.aiText, 'two glasses of water and a cold brew');
      expect(state.aiResult, isNotNull);
    });

    test('triggerPhotoSim sets AI text to photo sample', () {
      final state = AppState();
      state.triggerPhotoSim();
      expect(state.aiText, isNotEmpty);
      expect(state.aiResult, isNotNull);
    });

    test('confirmAiLog logs items, clears state, and navigates home', () {
      final state = AppState();
      state.setAiText('16 oz coffee');
      final initialEntriesCount = state.entries.length;

      state.confirmAiLog();
      expect(state.entries.length, initialEntriesCount + 1);
      expect(state.entries.last.name, 'Coffee');
      expect(state.entries.last.oz, 16.0);
      expect(state.aiText, '');
      expect(state.aiResult, isNull);
      expect(state.currentScreen, 'home');
    });

    test('confirmAiLog does nothing if aiResult is null or empty', () {
      final state = AppState();
      state.clearAi();
      final initialEntriesCount = state.entries.length;

      state.confirmAiLog();
      expect(state.entries.length, initialEntriesCount);
    });

    test('toggleAdaptiveReminders flips active setting', () {
      final state = AppState();
      final initial = state.adaptiveReminders;
      state.toggleAdaptiveReminders();
      expect(state.adaptiveReminders, !initial);
    });

    test('incrementInterval and decrementInterval enforce bounds', () {
      final state = AppState();

      // Standard interval starts at 90
      state.incrementInterval();
      expect(state.reminderInterval, 105);

      state.decrementInterval();
      expect(state.reminderInterval, 90);

      // Decrease to bounds (30)
      for (int i = 0; i < 10; i++) {
        state.decrementInterval();
      }
      expect(state.reminderInterval, 30);
      state.decrementInterval(); // should remain at 30
      expect(state.reminderInterval, 30);

      // Increase to bounds (240)
      for (int i = 0; i < 20; i++) {
        state.incrementInterval();
      }
      expect(state.reminderInterval, 240);
      state.incrementInterval(); // should remain at 240
      expect(state.reminderInterval, 240);
    });

    test('toggleReminderRow toggles enabled state of item', () {
      final state = AppState();
      final initial = state.reminders[2]['enabled'];
      state.toggleReminderRow(2);
      expect(state.reminders[2]['enabled'], !initial);
    });

    test(
      'toggleHealthConnect and syncNow update Health Connect status',
      () async {
        final state = AppState();
        // Let init complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Disconnect (sync path — no async needed since already connected)
        state.toggleHealthConnect();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(state.healthConnectConnected, false);
        expect(state.toastMessage, 'Disconnected');

        // Reconnect (async path — _requestHealthPermissions is awaited internally)
        state.toggleHealthConnect();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(state.healthConnectConnected, true);
        expect(state.lastSyncStr, 'just now');

        await state.syncNow();
        expect(state.lastSyncStr, 'just now');
        expect(state.toastMessage, 'Synced with Health Connect');
      },
    );

    test('togglePermission flips the toggle at the index', () {
      final state = AppState();
      final initial = state.permissions[1]['enabled'];
      state.togglePermission(1);
      expect(state.permissions[1]['enabled'], !initial);
    });

    test('adjustOnbGoal adjusts goal within limits of 48 and 200', () {
      final state = AppState();
      expect(state.onbGoal, 100.0);

      state.adjustOnbGoal(20.0);
      expect(state.onbGoal, 120.0);

      state.adjustOnbGoal(-100.0); // should clamp to 48
      expect(state.onbGoal, 48.0);

      state.adjustOnbGoal(200.0); // should clamp to 200
      expect(state.onbGoal, 200.0);
    });

    test('toggleOnbConnect flips the connect toggle', () {
      final state = AppState();
      final initial = state.onbConnect;
      state.toggleOnbConnect();
      expect(state.onbConnect, !initial);
    });

    test('finishOnboarding copies values to state and navigates home', () {
      final state = AppState();
      state.adjustOnbGoal(50.0); // onboard goal is 150
      state.toggleOnbConnect(); // false

      state.finishOnboarding();
      expect(state.goalOz, 150.0);
      expect(state.healthConnectConnected, false);
      expect(state.currentScreen, 'home');
      expect(state.toastMessage, "You're all set");
    });

    test('totalConsumedToday and weeklyHydrationData calculations', () {
      final state = AppState();

      // Let's clear mock entries first to get clean results
      state.entries.clear();
      expect(state.totalConsumedToday, 0.0);

      final today = DateTime.now();
      state.addDrinkEntry(
        DrinkEntry(
          id: 'e1',
          name: 'Water',
          icon: 'water_drop',
          oz: 12.0,
          hydration: 12.0,
          time: today,
          source: 'Quick add',
        ),
      );
      state.addDrinkEntry(
        DrinkEntry(
          id: 'e2',
          name: 'Coffee',
          icon: 'local_cafe',
          oz: 8.0,
          hydration: 6.4,
          time: today,
          source: 'Quick add',
        ),
      );

      // Add an entry with yesterday's time to ensure it is not counted today
      state.addDrinkEntry(
        DrinkEntry(
          id: 'e3',
          name: 'Water',
          icon: 'water_drop',
          oz: 16.0,
          hydration: 16.0,
          time: today.subtract(const Duration(days: 1)),
          source: 'Quick add',
        ),
      );

      expect(state.totalConsumedToday, 18.4);
      expect(state.weeklyHydrationData.last, 18.4);
      expect(state.weeklyHydrationData.length, 7);
    });

    test(
      'Health Connect permission types and writing Coffee works without throwing',
      () async {
        final state = AppState();

        // Verify permissions list length and details
        expect(state.permissions[2]['label'], 'Nutrition');

        // Log Coffee to trigger writeNutritionToHealthConnect code path
        state.addDrinkEntry(
          DrinkEntry(
            id: 'coffee-test-id',
            name: 'Coffee',
            icon: 'local_cafe',
            oz: 8.0,
            hydration: 6.4,
            time: DateTime.now(),
            source: 'Quick add',
          ),
        );

        // Ensure no exceptions were thrown and entry is registered in state
        expect(state.entries.any((e) => e.id == 'coffee-test-id'), true);
      },
    );

    test(
      'setWakeTime and setSleepTime update time settings and persist',
      () async {
        final state = AppState();
        await Future.delayed(const Duration(milliseconds: 300));

        state.setWakeTime('6:30 AM');
        state.setSleepTime('11:00 PM');

        expect(state.wakeTime, '6:30 AM');
        expect(state.sleepTime, '11:00 PM');

        await Future.delayed(const Duration(milliseconds: 50));
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('wakeTime'), '6:30 AM');
        expect(prefs.getString('sleepTime'), '11:00 PM');
      },
    );

    test('currentStreak calculates consecutive days meeting goal', () async {
      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 150));
      state.entries.clear();

      final now = DateTime.now();

      // Today: met goal (100 oz)
      state.addDrinkEntry(
        DrinkEntry(
          id: 's1',
          name: 'Water',
          icon: 'water_drop',
          oz: 100.0,
          hydration: 100.0,
          time: now,
          source: 'Test',
        ),
      );

      // Yesterday: met goal (100 oz)
      state.addDrinkEntry(
        DrinkEntry(
          id: 's2',
          name: 'Water',
          icon: 'water_drop',
          oz: 100.0,
          hydration: 100.0,
          time: now.subtract(const Duration(days: 1)),
          source: 'Test',
        ),
      );

      // 2 days ago: met goal (100 oz)
      state.addDrinkEntry(
        DrinkEntry(
          id: 's3',
          name: 'Water',
          icon: 'water_drop',
          oz: 100.0,
          hydration: 100.0,
          time: now.subtract(const Duration(days: 2)),
          source: 'Test',
        ),
      );

      // 3 days ago: missed goal (30 oz) -> breaks streak
      state.addDrinkEntry(
        DrinkEntry(
          id: 's4',
          name: 'Water',
          icon: 'water_drop',
          oz: 30.0,
          hydration: 30.0,
          time: now.subtract(const Duration(days: 3)),
          source: 'Test',
        ),
      );

      expect(state.currentStreak, 3);
    });

    test(
      'weeklyHydrationData sums entries for each of the last 7 calendar days',
      () async {
        final state = AppState();
        await Future.delayed(const Duration(milliseconds: 50));
        state.entries.clear();

        final now = DateTime.now();
        // Add entry 3 days ago
        state.addDrinkEntry(
          DrinkEntry(
            id: 'w1',
            name: 'Water',
            icon: 'water_drop',
            oz: 50.0,
            hydration: 50.0,
            time: now.subtract(const Duration(days: 3)),
            source: 'Test',
          ),
        );

        final weeklyData = state.weeklyHydrationData;
        expect(weeklyData.length, 7);
        // Index 3 (3 days ago from today, which is index 6) should be 50.0
        expect(weeklyData[3], 50.0);
      },
    );

    test('hydrationInsight returns dynamic recommendations', () async {
      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 50));
      state.entries.clear();

      expect(state.hydrationInsight, isNotEmpty);
    });

    test('otherApps list initialization and toggleOtherApp', () async {
      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(state.otherApps.length, 3);
      expect(state.otherApps[0]['name'], 'Google Fit');

      final initialStatus = state.otherApps[1]['connected'];
      state.toggleOtherApp(1); // toggle Samsung Health

      expect(state.otherApps[1]['connected'], !initialStatus);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('otherApps'), isNotNull);
    });
  });
}

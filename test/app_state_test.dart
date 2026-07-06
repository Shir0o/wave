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
        expect(state.entries.length, 3); // mock default entries
        expect(state.adaptiveReminders, true);
        expect(state.reminderInterval, 90);
        expect(state.healthConnectConnected, true);
        expect(state.lastSyncStr, '2 min ago');
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

    test('toggleHealthConnect and syncNow update Health Connect status', () {
      final state = AppState();
      state.toggleHealthConnect();
      expect(state.healthConnectConnected, false);
      expect(state.toastMessage, 'Disconnected');

      state.toggleHealthConnect();
      expect(state.healthConnectConnected, true);
      expect(state.lastSyncStr, 'just now');

      state.syncNow();
      expect(state.lastSyncStr, 'just now');
      expect(state.toastMessage, 'Synced with Health Connect');
    });

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
  });
}

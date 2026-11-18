import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/main.dart';
import 'package:wave/models/drink_entry.dart';
import 'package:wave/screens/home_screen.dart';
import 'package:wave/screens/onboarding_screen.dart';
import 'package:wave/screens/reminders_screen.dart';
import 'package:wave/screens/smart_log_screen.dart';
import 'package:wave/screens/sync_screen.dart';
import 'package:wave/state/app_state.dart';
import 'mock_health.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockPlatformChannels();

  setUpAll(() async {
    // google_fonts fetches a font per weight at runtime, which a widget test
    // can never satisfy. Disabling fetching keeps the suite off the network;
    // the metric-matched families registered below still render every label.
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadAuditFonts();
  });

  final variants = [
    (
      name: 'phone_light',
      size: const Size(390, 844),
      textScale: 1.0,
      isDark: false,
    ),
    (
      name: 'phone_dark',
      size: const Size(390, 844),
      textScale: 1.0,
      isDark: true,
    ),
    (
      name: 'small_large_font',
      size: const Size(320, 568),
      textScale: 1.6,
      isDark: false,
    ),
  ];

  for (final variant in variants) {
    testWidgets('UI/UX Matrix Audit: ${variant.name}', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'isDarkTheme': variant.isDark});

      await tester.binding.setSurfaceSize(variant.size);
      tester.view.physicalSize = variant.size;
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = variant.textScale;

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final state = AppState();
      if (variant.isDark) {
        state.toggleTheme();
      }

      // Populate realistic entries
      final now = DateTime.now();
      state.addDrinkEntry(
        DrinkEntry(
          id: 'drink_water',
          name: 'Water',
          icon: 'water_drop',
          oz: 16.0,
          hydration: 16.0,
          time: now.subtract(const Duration(hours: 2)),
          source: 'Quick add',
        ),
      );
      state.addDrinkEntry(
        DrinkEntry(
          id: 'drink_coffee',
          name: 'Coffee',
          icon: 'local_cafe',
          oz: 12.0,
          hydration: 10.0,
          time: now.subtract(const Duration(minutes: 30)),
          source: 'Quick add',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const WaveApp(),
        ),
      );

      // Allow wave animation, layout frames, and toast timer to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 2000));

      // Golden screenshot capture
      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byType(WaveApp),
          matchesGoldenFile('goldens/${variant.name}.png'),
        );
      }

      // Check for zero RenderFlex overflows
      expect(
        tester.takeException(),
        isNull,
        reason: 'Zero RenderFlex overflow check failed for ${variant.name}',
      );

      // Usability and accessibility guideline audits
      final semanticsHandle = tester.ensureSemantics();
      try {
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        semanticsHandle.dispose();
      }
    });
  }

  // Interactive end-to-end click-through audit at phone size. Each primary
  // screen, sheet and dialog is reached the way a person would reach it, then
  // checked for layout exceptions, tap-target size, text contrast, and a golden
  // frame (goldens are only written with `flutter test --update-goldens`).
  final e2eThemes = [
    (name: 'light', isDark: false),
    (name: 'dark', isDark: true),
  ];

  for (final theme in e2eThemes) {
    testWidgets('E2E Click-Through Audit: 390x844 ${theme.name}', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'isDarkTheme': theme.isDark});

      await tester.binding.setSurfaceSize(const Size(390, 844));
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final state = AppState();
      if (theme.isDark) {
        state.toggleTheme();
      }

      final now = DateTime.now();
      state.addDrinkEntry(
        DrinkEntry(
          id: 'e2e_water',
          name: 'Water',
          icon: 'water_drop',
          oz: 16.0,
          hydration: 16.0,
          time: now.subtract(const Duration(hours: 2)),
          source: 'Quick add',
        ),
      );
      state.addDrinkEntry(
        DrinkEntry(
          id: 'e2e_coffee',
          name: 'Coffee',
          icon: 'local_cafe',
          oz: 12.0,
          hydration: 10.0,
          time: now.subtract(const Duration(minutes: 30)),
          source: 'Quick add',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const WaveApp(),
        ),
      );
      await _pumpFrames(tester, const Duration(seconds: 2));

      final semanticsHandle = tester.ensureSemantics();
      final audit = _ClickThroughAudit(tester, 'e2e_${theme.name}');
      try {
        // 01 - Landing tab.
        expect(find.text("Today's drinks"), findsOneWidget);
        await audit.step('01_home');

        // 02 - Theme toggle control (and back again).
        final expectedDark = !state.isDarkTheme;
        await tester.tap(
          find.byTooltip(
            state.isDarkTheme ? 'Switch to light mode' : 'Switch to dark mode',
          ),
        );
        await audit.step('02_theme_toggle');
        expect(state.isDarkTheme, expectedDark);
        await tester.tap(
          find.byTooltip(
            state.isDarkTheme ? 'Switch to light mode' : 'Switch to dark mode',
          ),
        );
        await audit.step('03_theme_restored');

        // 04 - Quick add control on the home tab.
        final entriesBeforeQuickAdd = state.entries.length;
        await tester.tap(
          find.descendant(
            of: find.byType(HomeScreen),
            matching: find.text('Glass'),
          ),
        );
        await audit.step('04_quick_add_glass');
        expect(state.entries.length, entriesBeforeQuickAdd + 1);
        expect(state.toastMessage, isNotNull);
        await _pumpFrames(tester, const Duration(milliseconds: 2100));

        // 05 - Smart log banner opens the smart log screen.
        await tester.tap(
          find.descendant(
            of: find.byType(HomeScreen),
            matching: find.text('Smart log'),
          ),
        );
        await audit.step('05_smart_log');
        expect(state.currentScreen, 'log');

        // 06 - Suggestion chip parses into a result card.
        final chipFinder = find.descendant(
          of: find.byType(SmartLogScreen),
          matching: find.text('500 ml sparkling water'),
        );
        await tester.ensureVisible(chipFinder);
        await tester.pump();
        await tester.tap(chipFinder);
        await audit.step('06_smart_log_result');
        expect(state.aiResult, isNotNull);
        expect(state.aiResult!.items, isNotEmpty);

        // 07 - Confirm the parsed batch and return home.
        final entriesBeforeAiLog = state.entries.length;
        final logAllFinder = find.descendant(
          of: find.byType(SmartLogScreen),
          matching: find.text('Log all drinks'),
        );
        await tester.ensureVisible(logAllFinder);
        await tester.pump();
        await tester.tap(logAllFinder);
        await audit.step('07_home_after_smart_log');
        expect(state.currentScreen, 'home');
        expect(state.entries.length, greaterThan(entriesBeforeAiLog));
        await _pumpFrames(tester, const Duration(milliseconds: 2100));

        // 08 - Primary tab: reminders.
        await tester.tap(_navTab('Reminders'));
        await audit.step('08_reminders');
        expect(state.currentScreen, 'reminders');
        expect(find.text('SCHEDULED TIMES'), findsOneWidget);

        // 09 - Active hours dialog.
        await tester.tap(
          find.descendant(
            of: find.byType(RemindersScreen),
            matching: find.text('Active hours'),
          ),
        );
        await audit.step('09_active_hours_dialog');
        expect(find.byType(AlertDialog), findsOneWidget);

        // 10 - Wake time picker launched from the dialog.
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Wake Time'),
          ),
        );
        await audit.step(
          '10_wake_time_picker',
          settle: const Duration(milliseconds: 600),
        );
        expect(find.byType(TimePickerDialog), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(TimePickerDialog),
            matching: find.text('Cancel'),
          ),
        );
        await _pumpFrames(tester, const Duration(milliseconds: 400));
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Done'),
          ),
        );
        await _pumpFrames(tester, const Duration(milliseconds: 400));

        // 11 - Interval stepper.
        final intervalBefore = state.reminderInterval;
        await tester.tap(
          find.descendant(
            of: find.byType(RemindersScreen),
            matching: find.byIcon(Icons.add),
          ),
        );
        await audit.step('11_reminders_interval');
        expect(state.reminderInterval, intervalBefore + 15);

        // 12 - Adaptive reminders switch.
        await tester.tap(
          find
              .descendant(
                of: find.byType(RemindersScreen),
                matching: find.byType(Switch),
              )
              .first,
        );
        await audit.step('12_adaptive_reminders_off');
        expect(state.adaptiveReminders, isFalse);

        // 13 - Primary tab: trends.
        await tester.tap(_navTab('Trends'));
        await audit.step(
          '13_trends',
          settle: const Duration(milliseconds: 800),
        );
        expect(state.currentScreen, 'stats');
        expect(find.text('STREAK'), findsOneWidget);

        // 14 - Primary tab: sync / settings.
        await tester.tap(_navTab('Sync'));
        await audit.step('14_sync');
        expect(state.currentScreen, 'sync');
        expect(find.text('PERMISSIONS'), findsOneWidget);

        // 15 - Manual sync action.
        await tester.tap(
          find.descendant(
            of: find.byType(SyncScreen),
            matching: find.text('Sync now'),
          ),
        );
        await audit.step('15_sync_now');
        expect(state.lastSyncStr, 'just now');
        await _pumpFrames(tester, const Duration(milliseconds: 2100));

        // 16 - Other-app connection dialog.
        final otherAppFinder = find.text('Google Fit');
        await tester.ensureVisible(otherAppFinder);
        await tester.pump();
        await tester.tap(otherAppFinder);
        await audit.step('16_google_fit_dialog');
        expect(find.byType(AlertDialog), findsOneWidget);

        // 17 - Confirm disconnect from that dialog.
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Disconnect'),
          ),
        );
        await audit.step('17_google_fit_disconnected');
        expect(state.otherApps.first['connected'], isFalse);

        // 18 - Replay setup opens onboarding.
        final replayFinder = find.descendant(
          of: find.byType(SyncScreen),
          matching: find.text('Replay setup'),
        );
        await tester.ensureVisible(replayFinder);
        await tester.pump();
        await tester.tap(replayFinder);
        await audit.step('18_onboarding');
        expect(state.currentScreen, 'onboard');
        expect(find.text('Ride your\nhydration wave.'), findsOneWidget);

        // 19 - Onboarding goal stepper.
        final goalBefore = state.onbGoal;
        await tester.tap(
          find.descendant(
            of: find.byType(OnboardingScreen),
            matching: find.byIcon(Icons.add),
          ),
        );
        await audit.step('19_onboarding_goal');
        expect(state.onbGoal, goalBefore + 8);

        // 20 - Onboarding Health Connect consent switch.
        await tester.tap(
          find.descendant(
            of: find.byType(OnboardingScreen),
            matching: find.byType(Switch),
          ),
        );
        await audit.step('20_onboarding_connect_off');
        expect(state.onbConnect, isFalse);
        await tester.tap(
          find.descendant(
            of: find.byType(OnboardingScreen),
            matching: find.byType(Switch),
          ),
        );
        await _pumpFrames(tester, const Duration(milliseconds: 400));

        // 21 - Finish onboarding back into the shell.
        await tester.tap(
          find.descendant(
            of: find.byType(OnboardingScreen),
            matching: find.text('Dive in'),
          ),
        );
        await audit.step('21_home_after_onboarding');
        expect(state.currentScreen, 'home');
        await _pumpFrames(tester, const Duration(milliseconds: 2600));

        // 22 - Central FAB opens smart log.
        await tester.tap(find.byType(FloatingActionButton));
        await audit.step('22_smart_log_from_fab');
        expect(state.currentScreen, 'log');

        // 23 - Back arrow returns home.
        await tester.tap(
          find.descendant(
            of: find.byType(SmartLogScreen),
            matching: find.byIcon(Icons.arrow_back_rounded),
          ),
        );
        await audit.step('23_home_from_smart_log');
        expect(state.currentScreen, 'home');

        // 24 - Swipe to delete a logged drink.
        final entriesBeforeSwipe = state.entries.length;
        final dismissible = find.byType(Dismissible).first;
        await tester.ensureVisible(dismissible);
        await tester.pump();
        await tester.drag(dismissible, const Offset(-500, 0));
        await audit.step(
          '24_home_after_swipe_delete',
          settle: const Duration(milliseconds: 700),
        );
        expect(state.entries.length, entriesBeforeSwipe - 1);
        await _pumpFrames(tester, const Duration(milliseconds: 2100));
      } finally {
        semanticsHandle.dispose();
      }

      // Report every accessibility / layout violation in one failure so a
      // single run lists all screens that need work.
      if (audit.failures.isNotEmpty) {
        fail(
          'UI/UX E2E audit failures for 390x844 ${theme.name}:\n\n'
          '${audit.failures.join('\n\n')}',
        );
      }
    });
  }
}

Finder _navTab(String label) {
  return find.descendant(
    of: find.byType(BottomAppBar),
    matching: find.text(label),
  );
}

/// Pumps a fixed number of frames. The app runs continuous wave animations, so
/// `pumpAndSettle` would never return.
Future<void> _pumpFrames(WidgetTester tester, Duration duration) async {
  const step = Duration(milliseconds: 100);
  await tester.pump();
  var remaining = duration;
  while (remaining > Duration.zero) {
    final slice = remaining > step ? step : remaining;
    await tester.pump(slice);
    remaining -= slice;
  }
}

/// Collects layout and accessibility findings for one interactive step at a
/// time, keeping the flow running so the whole app is audited in a single pass.
class _ClickThroughAudit {
  _ClickThroughAudit(this.tester, this.variant);

  final WidgetTester tester;
  final String variant;
  final List<String> failures = [];

  Future<void> step(
    String name, {
    Duration settle = const Duration(milliseconds: 400),
  }) async {
    await _pumpFrames(tester, settle);

    Object? exception;
    while ((exception = tester.takeException()) != null) {
      failures.add('[$name] Layout/rendering exception: $exception');
    }

    final tapTargets = await androidTapTargetGuideline.evaluate(tester);
    if (!tapTargets.passed) {
      failures.add(
        '[$name] Tap targets smaller than 48x48 dp:\n'
        '${tapTargets.reason ?? '(no reason reported)'}',
      );
    }

    final contrast = await textContrastGuideline.evaluate(tester);
    if (!contrast.passed) {
      failures.add(
        '[$name] Text contrast below WCAG AA:\n'
        '${contrast.reason ?? '(no reason reported)'}',
      );
    }

    if (autoUpdateGoldenFiles) {
      await expectLater(
        find.byType(WaveApp),
        matchesGoldenFile('goldens/${variant}_$name.png'),
      );
    }
  }
}

/// Registers the Flutter SDK's Roboto font under the Google Fonts family names
/// used by the app. Widget tests cannot fetch Google Fonts, and the built-in
/// test font is far wider than Fredoka, which would report overflows that only
/// exist in the test environment. Best effort: if the SDK fonts are missing the
/// audit still runs with the default test font.
Future<void> _loadAuditFonts() async {
  final fontDir = _materialFontsDirectory();
  if (fontDir == null) {
    return;
  }

  const families = {
    'Fredoka': 'Roboto-Regular.ttf',
    // Google Fonts names each weight-specific family after its variant:
    // w400 -> "Fredoka_regular", w500 -> "Fredoka_500", w600 -> "Fredoka_600".
    'Fredoka_regular': 'Roboto-Regular.ttf',
    'Fredoka_500': 'Roboto-Medium.ttf',
    'Fredoka_600': 'Roboto-Medium.ttf',
    'Fredoka_700': 'Roboto-Bold.ttf',
  };

  for (final entry in families.entries) {
    final file = File('${fontDir.path}/${entry.value}');
    if (!file.existsSync()) {
      continue;
    }
    final bytes = await file.readAsBytes();
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  // Material icons are not bundled into widget tests by default, so load the
  // SDK copy to keep icons visible in the audit goldens.
  final iconFile = File('${fontDir.path}/MaterialIcons-Regular.otf');
  if (iconFile.existsSync()) {
    final bytes = await iconFile.readAsBytes();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}

/// Finds the Flutter SDK's cached Material fonts.
///
/// CI runners do not always export `FLUTTER_ROOT` to the test process, but
/// `flutter test` always spawns `flutter_tester` from
/// `<sdk>/bin/cache/artifacts/engine/<platform>/`, so walk up from the running
/// executable as well. Returns null when neither lookup finds the cache, in
/// which case the audit runs with Flutter's built-in test font.
Directory? _materialFontsDirectory() {
  final candidates = <Directory>[];
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    candidates.add(
      Directory('$flutterRoot/bin/cache/artifacts/material_fonts'),
    );
  }

  var dir = File(Platform.resolvedExecutable).parent;
  for (var depth = 0; depth < 8; depth++) {
    candidates.add(Directory('${dir.path}/bin/cache/artifacts/material_fonts'));
    final parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }

  for (final candidate in candidates) {
    if (candidate.existsSync()) {
      return candidate;
    }
  }
  return null;
}

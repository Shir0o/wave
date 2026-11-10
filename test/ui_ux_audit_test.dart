import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/main.dart';
import 'package:wave/models/drink_entry.dart';
import 'package:wave/state/app_state.dart';
import 'mock_health.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockPlatformChannels();

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
}

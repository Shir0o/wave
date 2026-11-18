import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wave/theme/app_theme.dart';
import 'package:wave/theme/wave_theme.dart';

/// WCAG 2.x relative contrast ratio between two opaque colours.
double _contrast(Color foreground, Color background) {
  final double a = foreground.computeLuminance();
  final double b = background.computeLuminance();
  final double lighter = a > b ? a : b;
  final double darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

/// The colour the contrast audit samples from an antialiased glyph edge, where
/// only part of the pixel is covered by the ink.
Color _blend(Color ink, Color background, double coverage) {
  return Color.alphaBlend(ink.withValues(alpha: coverage), background);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('light-mode ink tokens', () {
    test('secondary and tertiary text clear 6:1 nominally', () {
      final light = AppThemeColors.light;
      final surfaces = <Color>[
        light.surface,
        light.bg,
        light.surfaceSoft,
        light.surfaceTint,
      ];

      for (final surface in surfaces) {
        expect(_contrast(light.text2, surface), greaterThanOrEqualTo(6.0));
        expect(_contrast(light.text3, surface), greaterThanOrEqualTo(6.0));
      }
    });

    test(
      'small labels survive glyph antialiasing on white and page surface',
      () {
        final light = AppThemeColors.light;

        for (final surface in <Color>[light.surface, light.bg]) {
          // Flutter's textContrastGuideline picks the most common pixel inside a
          // glyph box, which on Linux/desktop renderers is a partly covered
          // blend rather than the raw ink. 85% coverage models the worst case
          // the CI audit has produced, and must still clear WCAG AA.
          expect(
            _contrast(_blend(light.text2, surface, 0.85), surface),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            _contrast(_blend(light.text3, surface, 0.85), surface),
            greaterThanOrEqualTo(4.5),
          );
        }
      },
    );
  });

  group('dark-mode ink tokens', () {
    test('secondary and tertiary text clear AA on every dark surface', () {
      final dark = AppThemeColors.dark;
      final surfaces = <Color>[
        dark.surface,
        dark.bg,
        dark.surfaceSoft,
        dark.surfaceTint,
      ];

      for (final surface in surfaces) {
        expect(_contrast(dark.text2, surface), greaterThanOrEqualTo(4.5));
        expect(_contrast(dark.text3, surface), greaterThanOrEqualTo(4.5));
      }
    });
  });

  group('Material theme', () {
    test('uses Wave accents instead of the Material purple baseline', () {
      final light = buildWaveTheme(AppThemeColors.light, Brightness.light);
      final dark = buildWaveTheme(AppThemeColors.dark, Brightness.dark);

      expect(light.colorScheme.primary, AppThemeColors.light.accent2);
      expect(dark.colorScheme.primary, AppThemeColors.dark.accent2);
      expect(light.colorScheme.surface, AppThemeColors.light.surface);
      expect(dark.colorScheme.surface, AppThemeColors.dark.surface);
    });

    test('time picker Cancel/OK text clears 5.5:1 and its AA blend', () {
      for (final theme in [
        buildWaveTheme(AppThemeColors.light, Brightness.light),
        buildWaveTheme(AppThemeColors.dark, Brightness.dark),
      ]) {
        final picker = theme.timePickerTheme;
        final background = picker.backgroundColor!;

        for (final style in [
          picker.cancelButtonStyle,
          picker.confirmButtonStyle,
        ]) {
          final ink = style!.foregroundColor!.resolve(<WidgetState>{});
          expect(ink, isNotNull);
          expect(_contrast(ink!, background), greaterThanOrEqualTo(5.5));
          expect(
            _contrast(_blend(ink, background, 0.75), background),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
    });
  });
}

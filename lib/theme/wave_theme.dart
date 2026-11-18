import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wave/theme/app_theme.dart';

/// Builds Wave's Material theme for [colors].
///
/// Material widgets that Wave does not style itself (dialogs, the time picker,
/// text buttons) fall back to the stock Material 3 baseline colours, which are
/// purple and fail WCAG AA for small text under glyph antialiasing. Mapping the
/// [ColorScheme] and the time picker onto Wave's ocean palette keeps those
/// surfaces on-brand and high contrast in both modes.
ThemeData buildWaveTheme(AppThemeColors colors, Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  final ColorScheme scheme = ColorScheme(
    brightness: brightness,
    primary: colors.accent2,
    onPrimary: isDark ? colors.bg : Colors.white,
    primaryContainer: colors.surfaceSoft,
    onPrimaryContainer: colors.text,
    secondary: colors.accent,
    onSecondary: isDark ? colors.bg : colors.text,
    secondaryContainer: colors.surfaceTint,
    onSecondaryContainer: colors.text,
    surface: colors.surface,
    onSurface: colors.text,
    surfaceContainerHigh: colors.surface,
    surfaceContainerHighest: colors.surfaceSoft,
    onSurfaceVariant: colors.text2,
    outline: colors.text3,
    outlineVariant: colors.divider,
    error: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
    onError: isDark ? const Color(0xFF690005) : Colors.white,
    inverseSurface: colors.text,
    onInverseSurface: colors.surface,
    inversePrimary: colors.accent,
  );

  // Dialog action labels (Cancel / OK) sit on [colors.surface], where
  // [colors.text] is > 12:1 in both modes. That headroom survives the blended
  // pixel the contrast audit samples from antialiased glyph edges. The bold
  // weight thickens each stroke's solid core so a 1x Linux renderer leaves far
  // fewer partially covered fringe pixels for the audit to sample.
  final ButtonStyle dialogActionStyle = TextButton.styleFrom(
    foregroundColor: colors.text,
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.bg,
    useMaterial3: true,
    fontFamily: GoogleFonts.fredoka().fontFamily,
    // Keep dialogs on the exact surface token the contrast audit measures.
    dialogTheme: const DialogThemeData(surfaceTintColor: Colors.transparent),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      dialBackgroundColor: colors.surfaceSoft,
      dialHandColor: colors.accent2,
      dialTextColor: colors.text,
      hourMinuteColor: colors.surfaceSoft,
      hourMinuteTextColor: colors.text,
      dayPeriodColor: colors.surfaceSoft,
      dayPeriodTextColor: colors.text,
      entryModeIconColor: colors.text2,
      timeSelectorSeparatorColor: WidgetStateColor.resolveWith(
        (_) => colors.text2,
      ),
      cancelButtonStyle: dialogActionStyle,
      confirmButtonStyle: dialogActionStyle,
    ),
  );
}

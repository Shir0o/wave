import 'package:flutter_test/flutter_test.dart';
import 'package:wave/theme/app_theme.dart';

void main() {
  group('AppThemeColors Tests', () {
    test('light theme properties are initialized correctly', () {
      final theme = AppThemeColors.light;
      expect(theme.bg.value, 0xFFEEF8FF);
      expect(theme.heroTop.value, 0xFFE9F6FF);
      expect(theme.accent.value, 0xFF12B3C7);
    });

    test('dark theme properties are initialized correctly', () {
      final theme = AppThemeColors.dark;
      expect(theme.bg.value, 0xFF0A151F);
      expect(theme.heroTop.value, 0xFF102232);
      expect(theme.accent.value, 0xFF3FD0E6);
    });
  });
}

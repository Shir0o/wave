import 'package:flutter_test/flutter_test.dart';
import 'package:wave/theme/app_theme.dart';

void main() {
  group('AppThemeColors Tests', () {
    test('light theme properties are initialized correctly', () {
      final theme = AppThemeColors.light;
      expect(theme.bg.toARGB32(), 0xFFEEF8FF);
      expect(theme.heroTop.toARGB32(), 0xFFE9F6FF);
      expect(theme.accent.toARGB32(), 0xFF12B3C7);
    });

    test('dark theme properties are initialized correctly', () {
      final theme = AppThemeColors.dark;
      expect(theme.bg.toARGB32(), 0xFF0A151F);
      expect(theme.heroTop.toARGB32(), 0xFF102232);
      expect(theme.accent.toARGB32(), 0xFF3FD0E6);
    });
  });
}

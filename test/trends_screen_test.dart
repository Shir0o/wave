import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/screens/trends_screen.dart';
import 'package:wave/state/app_state.dart';
import 'mock_health.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockPlatformChannels();

  group('TrendsScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Renders TrendsScreen with proper stats and charts', (
      WidgetTester tester,
    ) async {
      final state = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: TrendsScreen()),
        ),
      );

      // Verify headers
      expect(find.text('Trends'), findsOneWidget);
      expect(find.text('STREAK'), findsOneWidget);
      expect(find.text('GOALS HIT'), findsOneWidget);
      expect(find.text('DAILY AVG'), findsOneWidget);
      expect(find.text('BEST DAY'), findsOneWidget);

      // Verify mock streak number
      expect(find.text('4'), findsOneWidget);
      expect(find.text(' days'), findsOneWidget);

      // Verify "This week" chart is present
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });
  });
}

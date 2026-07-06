import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/screens/sync_screen.dart';
import 'package:wave/state/app_state.dart';
import 'mock_health.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockPlatformChannels();

  group('SyncScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'Renders SyncScreen, toggles connection, syncs, and edits permissions',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final state = AppState();

        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: const MaterialApp(home: SyncScreen()),
          ),
        );

        // Verify page layout
        expect(find.text('Health Connect'), findsNWidgets(2));
        expect(find.text('PERMISSIONS'), findsOneWidget);
        expect(find.text('OTHER APPS'), findsOneWidget);
        expect(find.text('Replay setup'), findsOneWidget);

        // Verify connection card status is Connected initially
        expect(find.text('Connected & syncing'), findsOneWidget);

        // Find connection switch
        final switches = find.byType(Switch);
        expect(
          switches,
          findsAtLeastNWidgets(6),
        ); // 1 for HC, 5 for permissions

        // Tap the first switch (Health Connect connection)
        await tester.tap(switches.first);
        await tester.pump();
        expect(state.healthConnectConnected, false);
        expect(find.text('Not connected'), findsOneWidget);

        // Re-enable connection
        await tester.tap(switches.first);
        await tester.pump();
        expect(state.healthConnectConnected, true);

        // Tap "Sync now" button
        final syncNowBtn = find.text('Sync now');
        expect(syncNowBtn, findsOneWidget);
        await tester.tap(syncNowBtn);

        // syncNow triggers showToast with 1900ms timer
        await tester.pump(const Duration(seconds: 2));
        expect(state.lastSyncStr, 'just now');

        // Tap on a permission switch (read hydration - the first permission in the list, index 0, so switch at index 1)
        final initialReadHydrationEnabled = state.permissions[0]['enabled'];
        await tester.tap(switches.at(1));
        await tester.pump();
        expect(state.permissions[0]['enabled'], !initialReadHydrationEnabled);

        // Tap "Replay setup"
        final replayBtn = find.text('Replay setup');
        expect(replayBtn, findsOneWidget);
        await tester.tap(replayBtn);
        await tester.pump();
        expect(state.currentScreen, 'onboard');
      },
    );
  });
}

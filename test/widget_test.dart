import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wave/main.dart';
import 'package:wave/state/app_state.dart';

void main() {
  testWidgets('WaveApp home screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => AppState(), child: const WaveApp()),
    );

    // Pump a single frame to load UI, avoiding pumpAndSettle since infinite animations run
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the Home Screen elements are found
    expect(find.text("Today's drinks"), findsOneWidget);
    expect(find.text('Glass'), findsOneWidget);
    expect(find.text('Bottle'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
  });
}

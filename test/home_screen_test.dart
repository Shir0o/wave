import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/screens/home_screen.dart';
import 'package:wave/state/app_state.dart';
import 'package:wave/widgets/wave_painter.dart';
import 'mock_health.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockPlatformChannels();

  testWidgets('Hero wave fills the screen width instead of collapsing to 0', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: AppState(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final wavePaint = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is WavePainter,
    );

    expect(tester.getSize(wavePaint), const Size(800, 398));
  });
}

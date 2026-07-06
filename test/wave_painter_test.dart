import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave/widgets/wave_painter.dart';

void main() {
  group('WaveContainer and WavePainter Tests', () {
    testWidgets('WaveContainer renders correctly and animates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WaveContainer(
                fillPercentage: 0.5,
                fillTopColor: Colors.blue,
                fillBottomColor: Colors.indigo,
                waveColor1: Colors.cyan,
                waveColor2: Colors.teal,
              ),
            ),
          ),
        ),
      );

      // Verify that CustomPaint is rendered
      expect(
        find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter is WavePainter,
        ),
        findsOneWidget,
      );

      // Trigger animation updates
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('WaveContainer didUpdateWidget triggers fill transition', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WaveContainer(
                fillPercentage: 0.3,
                fillTopColor: Colors.blue,
                fillBottomColor: Colors.indigo,
                waveColor1: Colors.cyan,
                waveColor2: Colors.teal,
              ),
            ),
          ),
        ),
      );

      // Update widget with new fillPercentage
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WaveContainer(
                fillPercentage: 0.7,
                fillTopColor: Colors.blue,
                fillBottomColor: Colors.indigo,
                waveColor1: Colors.cyan,
                waveColor2: Colors.teal,
              ),
            ),
          ),
        ),
      );

      // Let animation play
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 800));
    });

    test('WavePainter shouldRepaint triggers correctly on property change', () {
      final bubbles = [
        Bubble(xPercent: 0.1, size: 5.0, durationRatio: 1.0, startDelay: 0.0),
      ];

      final painterBase = WavePainter(
        fillPercentage: 0.5,
        waveValue: 0.2,
        bubbleValue: 0.3,
        fillTopColor: Colors.blue,
        fillBottomColor: Colors.black,
        waveColor1: Colors.cyan,
        waveColor2: Colors.teal,
        bubbles: bubbles,
      );

      // Identical painter
      final painterIdentical = WavePainter(
        fillPercentage: 0.5,
        waveValue: 0.2,
        bubbleValue: 0.3,
        fillTopColor: Colors.blue,
        fillBottomColor: Colors.black,
        waveColor1: Colors.cyan,
        waveColor2: Colors.teal,
        bubbles: bubbles,
      );
      expect(painterBase.shouldRepaint(painterIdentical), false);

      // Different fillPercentage
      final painterDiffFill = WavePainter(
        fillPercentage: 0.6,
        waveValue: 0.2,
        bubbleValue: 0.3,
        fillTopColor: Colors.blue,
        fillBottomColor: Colors.black,
        waveColor1: Colors.cyan,
        waveColor2: Colors.teal,
        bubbles: bubbles,
      );
      expect(painterBase.shouldRepaint(painterDiffFill), true);

      // Different waveValue
      final painterDiffWave = WavePainter(
        fillPercentage: 0.5,
        waveValue: 0.3,
        bubbleValue: 0.3,
        fillTopColor: Colors.blue,
        fillBottomColor: Colors.black,
        waveColor1: Colors.cyan,
        waveColor2: Colors.teal,
        bubbles: bubbles,
      );
      expect(painterBase.shouldRepaint(painterDiffWave), true);

      // Different bubbleValue
      final painterDiffBubble = WavePainter(
        fillPercentage: 0.5,
        waveValue: 0.2,
        bubbleValue: 0.4,
        fillTopColor: Colors.blue,
        fillBottomColor: Colors.black,
        waveColor1: Colors.cyan,
        waveColor2: Colors.teal,
        bubbles: bubbles,
      );
      expect(painterBase.shouldRepaint(painterDiffBubble), true);

      // Different fillTopColor
      final painterDiffTopCol = WavePainter(
        fillPercentage: 0.5,
        waveValue: 0.2,
        bubbleValue: 0.3,
        fillTopColor: Colors.red,
        fillBottomColor: Colors.black,
        waveColor1: Colors.cyan,
        waveColor2: Colors.teal,
        bubbles: bubbles,
      );
      expect(painterBase.shouldRepaint(painterDiffTopCol), true);

      // Different fillBottomColor
      final painterDiffBotCol = WavePainter(
        fillPercentage: 0.5,
        waveValue: 0.2,
        bubbleValue: 0.3,
        fillTopColor: Colors.blue,
        fillBottomColor: Colors.red,
        waveColor1: Colors.cyan,
        waveColor2: Colors.teal,
        bubbles: bubbles,
      );
      expect(painterBase.shouldRepaint(painterDiffBotCol), true);

      // Different waveColor1
      final painterDiffW1 = WavePainter(
        fillPercentage: 0.5,
        waveValue: 0.2,
        bubbleValue: 0.3,
        fillTopColor: Colors.blue,
        fillBottomColor: Colors.black,
        waveColor1: Colors.red,
        waveColor2: Colors.teal,
        bubbles: bubbles,
      );
      expect(painterBase.shouldRepaint(painterDiffW1), true);

      // Different waveColor2
      final painterDiffW2 = WavePainter(
        fillPercentage: 0.5,
        waveValue: 0.2,
        bubbleValue: 0.3,
        fillTopColor: Colors.blue,
        fillBottomColor: Colors.black,
        waveColor1: Colors.cyan,
        waveColor2: Colors.red,
        bubbles: bubbles,
      );
      expect(painterBase.shouldRepaint(painterDiffW2), true);
    });
  });
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveContainer extends StatefulWidget {
  final double fillPercentage; // 0.0 to 1.0
  final Color fillTopColor;
  final Color fillBottomColor;
  final Color waveColor1;
  final Color waveColor2;
  final Widget? child;

  const WaveContainer({
    super.key,
    required this.fillPercentage,
    required this.fillTopColor,
    required this.fillBottomColor,
    required this.waveColor1,
    required this.waveColor2,
    this.child,
  });

  @override
  State<WaveContainer> createState() => _WaveContainerState();
}

class _WaveContainerState extends State<WaveContainer>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;
  late AnimationController _bubbleController;

  late Animation<double> _fillAnimation;

  final List<Bubble> _bubbles = [
    Bubble(xPercent: 0.22, size: 9.0, durationRatio: 1.0, startDelay: 0.0),
    Bubble(xPercent: 0.54, size: 6.0, durationRatio: 1.3, startDelay: 0.2),
    Bubble(xPercent: 0.78, size: 11.0, durationRatio: 1.16, startDelay: 0.1),
  ];

  @override
  void initState() {
    super.initState();
    // Wave oscillation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Smooth vertical fill adjustment
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fillAnimation =
        Tween<double>(
          begin: widget.fillPercentage,
          end: widget.fillPercentage,
        ).animate(
          CurvedAnimation(
            parent: _fillController,
            curve: const Cubic(0.34, 0.02, 0.16, 1.0),
          ),
        );

    // Bubble rising animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant WaveContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fillPercentage != widget.fillPercentage) {
      _fillAnimation =
          Tween<double>(
            begin: _fillAnimation.value,
            end: widget.fillPercentage,
          ).animate(
            CurvedAnimation(
              parent: _fillController,
              curve: const Cubic(0.34, 0.02, 0.16, 1.0),
            ),
          );
      _fillController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _waveController,
        _fillAnimation,
        _bubbleController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            fillPercentage: _fillAnimation.value,
            waveValue: _waveController.value,
            bubbleValue: _bubbleController.value,
            fillTopColor: widget.fillTopColor,
            fillBottomColor: widget.fillBottomColor,
            waveColor1: widget.waveColor1,
            waveColor2: widget.waveColor2,
            bubbles: _bubbles,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class Bubble {
  final double xPercent;
  final double size;
  final double durationRatio;
  final double startDelay;

  Bubble({
    required this.xPercent,
    required this.size,
    required this.durationRatio,
    required this.startDelay,
  });
}

class WavePainter extends CustomPainter {
  final double fillPercentage;
  final double waveValue;
  final double bubbleValue;
  final Color fillTopColor;
  final Color fillBottomColor;
  final Color waveColor1;
  final Color waveColor2;
  final List<Bubble> bubbles;

  WavePainter({
    required this.fillPercentage,
    required this.waveValue,
    required this.bubbleValue,
    required this.fillTopColor,
    required this.fillBottomColor,
    required this.waveColor1,
    required this.waveColor2,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double fillHeight = size.height * fillPercentage;
    final double baseWaterY = size.height - fillHeight;

    if (fillPercentage > 0) {
      // 1. Paint underlying gradient fill
      final rect = Rect.fromLTWH(0, baseWaterY, size.width, fillHeight);
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillTopColor, fillBottomColor],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      // Draw standard box for bottom area to make sure it is fully solid
      canvas.drawRect(
        Rect.fromLTWH(0, baseWaterY, size.width, fillHeight),
        fillPaint,
      );

      // 2. Paint Back Wave (waveColor2 - higher opacity/different phase)
      final backPath = Path();
      backPath.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x++) {
        final double phase = waveValue * 2 * math.pi * 2; // runs twice as fast
        final double sine = math.sin(x * 0.015 + phase + math.pi);
        final double y = baseWaterY - 14.0 + sine * 6.0;
        backPath.lineTo(x, y);
      }
      backPath.lineTo(size.width, size.height);
      backPath.close();

      canvas.drawPath(
        backPath,
        Paint()
          ..color = waveColor2
          ..style = PaintingStyle.fill,
      );

      // 3. Paint Front Wave (waveColor1)
      final frontPath = Path();
      frontPath.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x++) {
        final double phase = waveValue * 2 * math.pi;
        final double sine = math.sin(x * 0.012 + phase);
        final double y = baseWaterY - 20.0 + sine * 8.0;
        frontPath.lineTo(x, y);
      }
      frontPath.lineTo(size.width, size.height);
      frontPath.close();

      canvas.drawPath(
        frontPath,
        Paint()
          ..color = waveColor1
          ..style = PaintingStyle.fill,
      );

      // 4. Paint Bubbles inside the water
      for (final bubble in bubbles) {
        // Calculate bubble vertical progress (0.0 to 1.0)
        double progress =
            (bubbleValue / bubble.durationRatio) + bubble.startDelay;
        progress = progress % 1.0;

        // Custom easing curve for bubble rise
        final double bubbleProgressY = progress; // linear rise or ease-in
        final double startY = size.height - 20.0;
        final double endY = baseWaterY - 10.0; // stops around wave top
        final double currentY = startY - (startY - endY) * bubbleProgressY;

        // Fade calculation
        double opacity = 0.0;
        if (bubbleProgressY <= 0.15) {
          // Fade in to max 0.6
          opacity = (bubbleProgressY / 0.15) * 0.6;
        } else {
          // Fade out towards the top
          opacity = (1.0 - bubbleProgressY) / 0.85 * 0.6;
        }
        opacity = opacity.clamp(0.0, 1.0);

        if (opacity > 0 && currentY >= baseWaterY - 20) {
          final bubblePaint = Paint()
            ..color = Colors.white.withOpacity(opacity)
            ..style = PaintingStyle.fill;
          final double currentX = size.width * bubble.xPercent;
          canvas.drawCircle(
            Offset(currentX, currentY),
            bubble.size / 2,
            bubblePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.waveValue != waveValue ||
        oldDelegate.bubbleValue != bubbleValue ||
        oldDelegate.fillTopColor != fillTopColor ||
        oldDelegate.fillBottomColor != fillBottomColor ||
        oldDelegate.waveColor1 != waveColor1 ||
        oldDelegate.waveColor2 != waveColor2;
  }
}

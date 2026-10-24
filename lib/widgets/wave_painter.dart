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
  late AnimationController _frontWaveController;
  late AnimationController _backWaveController;
  late AnimationController _fillController;
  late AnimationController _bubbleController;

  late Animation<double> _fillAnimation;

  final List<Bubble> _bubbles = [
    Bubble(
      xPercent: 0.22,
      size: 9.0,
      durationRatio: 5.0 / 6.0,
      startDelay: 0.0,
      bottomOffset: 20.0,
      maxOpacity: 0.7,
    ),
    Bubble(
      xPercent: 0.54,
      size: 6.0,
      durationRatio: 6.5 / 6.0,
      startDelay: 0.23,
      bottomOffset: 12.0,
      maxOpacity: 0.6,
    ),
    Bubble(
      xPercent: 0.78,
      size: 11.0,
      durationRatio: 5.8 / 6.0,
      startDelay: 0.12,
      bottomOffset: 26.0,
      maxOpacity: 0.55,
    ),
  ];

  double _getEffectiveFill(double fill) =>
      math.max(0.08, fill.clamp(0.0, 1.0));

  @override
  void initState() {
    super.initState();
    // Front wave oscillation (7s linear infinite)
    _frontWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat();

    // Back wave oscillation (4.5s linear infinite)
    _backWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    // Smooth vertical fill adjustment (0.9s cubic-bezier(0.34, 0.02, 0.16, 1.0))
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final initialEffective = _getEffectiveFill(widget.fillPercentage);
    _fillAnimation = Tween<double>(
      begin: initialEffective,
      end: initialEffective,
    ).animate(
      CurvedAnimation(
        parent: _fillController,
        curve: const Cubic(0.34, 0.02, 0.16, 1.0),
      ),
    );

    // Bubble rising animation (6s loop)
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant WaveContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEffective = _getEffectiveFill(oldWidget.fillPercentage);
    final newEffective = _getEffectiveFill(widget.fillPercentage);
    if (oldEffective != newEffective) {
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: newEffective,
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
    _frontWaveController.dispose();
    _backWaveController.dispose();
    _fillController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _frontWaveController,
        _backWaveController,
        _fillAnimation,
        _bubbleController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            fillPercentage: _fillAnimation.value,
            waveValue: _frontWaveController.value,
            backWaveValue: _backWaveController.value,
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
  final double bottomOffset;
  final double maxOpacity;

  Bubble({
    required this.xPercent,
    required this.size,
    required this.durationRatio,
    required this.startDelay,
    this.bottomOffset = 20.0,
    this.maxOpacity = 0.6,
  });
}

class WavePainter extends CustomPainter {
  final double fillPercentage;
  final double waveValue;
  final double? backWaveValue;
  final double bubbleValue;
  final Color fillTopColor;
  final Color fillBottomColor;
  final Color waveColor1;
  final Color waveColor2;
  final List<Bubble> bubbles;

  WavePainter({
    required this.fillPercentage,
    required this.waveValue,
    this.backWaveValue,
    required this.bubbleValue,
    required this.fillTopColor,
    required this.fillBottomColor,
    required this.waveColor1,
    required this.waveColor2,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double effectivePercentage =
        math.max(0.08, fillPercentage.clamp(0.0, 1.0));
    final double fillHeight = size.height * effectivePercentage;
    final double baseWaterY = size.height - fillHeight;

    // 1. Paint underlying gradient fill
    final rect = Rect.fromLTWH(0, baseWaterY, size.width, fillHeight);
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillTopColor, fillBottomColor],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    // Solid base box
    canvas.drawRect(
      Rect.fromLTWH(0, baseWaterY, size.width, fillHeight),
      fillPaint,
    );

    // 2. Paint Back Wave (waveColor2 with 0.5 opacity, 4.5s cycle)
    final backPath = Path();
    backPath.moveTo(0, size.height);
    final double backOffset = (backWaveValue ?? waveValue) * 2 * math.pi;
    for (double x = 0; x <= size.width; x += 1.0) {
      final double sine = math.sin(x * 0.012 + backOffset + math.pi);
      final double y = baseWaterY - 18.0 + sine * 6.0;
      backPath.lineTo(x, y);
    }
    backPath.lineTo(size.width, size.height);
    backPath.close();

    canvas.drawPath(
      backPath,
      Paint()
        ..color = waveColor2.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );

    // 3. Paint Front Wave (waveColor1, 7s cycle)
    final frontPath = Path();
    frontPath.moveTo(0, size.height);
    final double frontOffset = waveValue * 2 * math.pi;
    for (double x = 0; x <= size.width; x += 1.0) {
      final double sine = math.sin(x * 0.010 + frontOffset);
      final double y = baseWaterY - 26.0 + sine * 8.0;
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

    // 4. Paint Bubbles inside the water with ease-in rise
    for (final bubble in bubbles) {
      double progress =
          (bubbleValue / bubble.durationRatio) + bubble.startDelay;
      progress = progress % 1.0;

      // Ease-in vertical rise (260px travel matching CSS keyframes rise)
      final double eased = progress * progress;
      final double currentY =
          (size.height - bubble.bottomOffset) - 260.0 * eased;

      // Fade calculation
      double opacity = 0.0;
      if (progress <= 0.15) {
        opacity = (progress / 0.15) * bubble.maxOpacity;
      } else {
        opacity = (1.0 - progress) / 0.85 * bubble.maxOpacity;
      }
      opacity = opacity.clamp(0.0, 1.0);

      if (opacity > 0 &&
          currentY >= baseWaterY - 10.0 &&
          currentY <= size.height) {
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

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.waveValue != waveValue ||
        oldDelegate.backWaveValue != backWaveValue ||
        oldDelegate.bubbleValue != bubbleValue ||
        oldDelegate.fillTopColor != fillTopColor ||
        oldDelegate.fillBottomColor != fillBottomColor ||
        oldDelegate.waveColor1 != waveColor1 ||
        oldDelegate.waveColor2 != waveColor2;
  }
}

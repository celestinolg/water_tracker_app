import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class WaterWavePainter extends CustomPainter {
  final double fillPercent; // 0.0 to 1.0
  final double waveAnimation;
  final Color waveColor;
  final Color waveColor2;

  WaterWavePainter({
    required this.fillPercent,
    required this.waveAnimation,
    this.waveColor = const Color(0x995DCCFC),
    this.waveColor2 = const Color(0x665DCCFC),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillHeight = size.height * (1 - fillPercent.clamp(0.0, 1.0));

    // Background water fill
    final fillPaint = Paint()
      ..color = AppColors.primarySurface
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, fillHeight, size.width, size.height - fillHeight),
      fillPaint,
    );

    // Wave 1
    _drawWave(
      canvas: canvas,
      size: size,
      fillHeight: fillHeight,
      amplitude: 8,
      phase: waveAnimation * 2 * pi,
      paint: Paint()
        ..color = waveColor
        ..style = PaintingStyle.fill,
    );

    // Wave 2 (offset)
    _drawWave(
      canvas: canvas,
      size: size,
      fillHeight: fillHeight + 4,
      amplitude: 6,
      phase: waveAnimation * 2 * pi + pi,
      paint: Paint()
        ..color = waveColor2
        ..style = PaintingStyle.fill,
    );
  }

  void _drawWave({
    required Canvas canvas,
    required Size size,
    required double fillHeight,
    required double amplitude,
    required double phase,
    required Paint paint,
  }) {
    final path = Path();
    path.moveTo(0, fillHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = fillHeight +
          amplitude * sin((x / size.width * 2 * pi) + phase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaterWavePainter oldDelegate) =>
      oldDelegate.fillPercent != fillPercent ||
      oldDelegate.waveAnimation != waveAnimation;
}

// Animated wave widget for use in circular progress
class AnimatedWaterWave extends StatefulWidget {
  final double fillPercent;
  final double size;
  final Widget? child;

  const AnimatedWaterWave({
    super.key,
    required this.fillPercent,
    required this.size,
    this.child,
  });

  @override
  State<AnimatedWaterWave> createState() => _AnimatedWaterWaveState();
}

class _AnimatedWaterWaveState extends State<AnimatedWaterWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: WaterWavePainter(
                fillPercent: widget.fillPercent,
                waveAnimation: _controller.value,
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

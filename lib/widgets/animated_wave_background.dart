import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedWaveBackground extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color waveColor;

  const AnimatedWaveBackground({
    super.key,
    required this.child,
    this.backgroundColor = Colors.grey,
    this.waveColor = const Color(0xFFE1E9F5),
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: widget.backgroundColor,
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  animation: _controller,
                  waveColor: widget.waveColor,
                ),
                child: Container(),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color waveColor;

  WavePainter({
    required this.animation,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final y = size.height * 0.8;
    path.moveTo(0, y);

    // Create multiple waves with different phases
    for (double x = 0; x <= size.width; x++) {
      final wave1 = math.sin(x / 60 + animation.value * 2 * math.pi) * 10;
      final wave2 = math.sin(x / 45 + animation.value * 2 * math.pi) * 8;
      final wave3 = math.sin(x / 30 + animation.value * 2 * math.pi) * 5;

      path.lineTo(x, y + wave1 + wave2 + wave3);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

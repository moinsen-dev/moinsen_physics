import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '_index.dart';

class NewtonCradlePainter extends CustomPainter {
  final List<Ball> balls;
  final double ballRadius;
  final Color ballColor;
  final double ballWeight;
  final bool useRubberBands;

  const NewtonCradlePainter({
    required this.balls,
    required this.ballRadius,
    required this.ballColor,
    required this.ballWeight,
    required this.useRubberBands,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSupportBar(canvas);
    _drawBalls(canvas);
    _drawSupportFeet(canvas);
  }

  void _drawSupportBar(Canvas canvas) {
    final barPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        balls.first.origin.dx - ballRadius,
        balls.first.origin.dy - 10,
        balls.last.origin.dx - balls.first.origin.dx + ballRadius * 2,
        10,
      ),
      barPaint,
    );
  }

  void _drawBalls(Canvas canvas) {
    for (var ball in balls) {
      _drawString(canvas, ball);
      _drawBall(canvas, ball);
      _drawWeightIndicator(canvas, ball);
    }
  }

  void _drawString(Canvas canvas, Ball ball) {
    if (useRubberBands) {
      _drawRubberBand(canvas, ball);
    } else {
      final stringPaint = Paint()
        ..color = Colors.grey[600]!
        ..strokeWidth = 1.0;
      canvas.drawLine(ball.origin, ball.position, stringPaint);
    }
  }

  void _drawRubberBand(Canvas canvas, Ball ball) {
    final rubberPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Calculate the control points for the bezier curve
    final dx = ball.position.dx - ball.origin.dx;
    final dy = ball.position.dy - ball.origin.dy;
    final midPoint = Offset(
      ball.origin.dx + dx * 0.5,
      ball.origin.dy + dy * 0.5,
    );

    // Add some waviness based on stretch
    final stretch = (ball.position - ball.origin).distance / ball.length;
    final waveMagnitude = (stretch - 1.0).clamp(0.0, 0.5) * 20.0;

    final controlPoint1 = Offset(
      midPoint.dx - waveMagnitude,
      midPoint.dy,
    );

    final controlPoint2 = Offset(
      midPoint.dx + waveMagnitude,
      midPoint.dy,
    );

    final path = Path()
      ..moveTo(ball.origin.dx, ball.origin.dy)
      ..cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        ball.position.dx,
        ball.position.dy,
      );

    canvas.drawPath(path, rubberPaint);
  }

  void _drawBall(Canvas canvas, Ball ball) {
    final ballPaint = Paint()..style = PaintingStyle.fill;

    final gradient = ui.Gradient.linear(
      ball.position - Offset(ballRadius, ballRadius),
      ball.position + Offset(ballRadius, ballRadius),
      [
        ballColor.withOpacity(0.8),
        ballColor,
        ballColor.withOpacity(0.6),
        ballColor.withOpacity(0.4),
      ],
      [0.0, 0.3, 0.7, 1.0],
    );
    ballPaint.shader = gradient;

    canvas.drawCircle(ball.position, ballRadius, ballPaint);

    _drawHighlights(canvas, ball);
  }

  void _drawHighlights(Canvas canvas, Ball ball) {
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.4);

    canvas.drawCircle(
      ball.position + Offset(-ballRadius * 0.3, -ballRadius * 0.3),
      ballRadius * 0.4,
      highlightPaint,
    );

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0;

    canvas.drawCircle(ball.position, ballRadius, rimPaint);
  }

  void _drawWeightIndicator(Canvas canvas, Ball ball) {
    double weightRatio = ballWeight / 100;
    if (weightRatio > 1.0) {
      final weightPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withOpacity(0.2)
        ..strokeWidth = 1.0;

      int circles = ((weightRatio - 1) * 3).round().clamp(0, 5);
      for (int i = 1; i <= circles; i++) {
        double radius = ballRadius - (i * 2);
        if (radius > 0) {
          canvas.drawCircle(ball.position, radius, weightPaint);
        }
      }
    }
  }

  void _drawSupportFeet(Canvas canvas) {
    final footPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    final footWidth = 20.0;
    final footHeight = 5.0;

    for (var offset in [balls.first.origin, balls.last.origin]) {
      canvas.drawRect(
        Rect.fromLTWH(
          offset.dx - footWidth / 2,
          offset.dy - 10,
          footWidth,
          footHeight,
        ),
        footPaint,
      );
    }
  }

  @override
  bool shouldRepaint(NewtonCradlePainter oldDelegate) =>
      oldDelegate.ballColor != ballColor ||
      oldDelegate.ballWeight != ballWeight;
}

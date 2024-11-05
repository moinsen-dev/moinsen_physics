import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'newton_cradle_game.dart';

class BallBody extends BodyComponent with ContactCallbacks {
  final Vector2 initialPosition;
  final double radius;
  final Color color;
  final double mass;
  @override
  final NewtonCradleGame game;

  BallBody({
    required this.initialPosition,
    required this.radius,
    required this.color,
    required this.mass,
    required this.game,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = initialPosition
      ..bullet = true
      ..userData = this;

    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = radius;

    body.createFixture(
      FixtureDef(shape)
        ..density = mass
        ..friction = 0.3
        ..restitution = 0.95,
    );

    return body;
  }

  @override
  void render(Canvas canvas) {
    if (game.supportBar == null) return;
    _drawRope(canvas);
    _drawBall(canvas);
  }

  void _drawRope(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = radius * 0.15
      ..style = PaintingStyle.stroke;

    final ropeStart = Vector2(0, -radius);
    final ropeEnd = game.supportBar!.position - body.position;

    canvas.drawLine(
      Offset(ropeStart.x, ropeStart.y),
      Offset(ropeEnd.x, ropeEnd.y),
      paint,
    );
  }

  void _drawBall(Canvas canvas) {
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.9,
      colors: [
        color.withOpacity(1.0),
        color.withOpacity(0.8),
        color.withOpacity(0.6),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final ballPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(
          center: Offset.zero,
          radius: radius,
        ),
      );

    canvas.drawCircle(Offset.zero, radius, ballPaint);
    _drawHighlight(canvas);
    _drawRim(canvas);
  }

  void _drawHighlight(Canvas canvas) {
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.5,
      highlightPaint,
    );
  }

  void _drawRim(Canvas canvas) {
    final rimPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08;

    canvas.drawCircle(Offset.zero, radius, rimPaint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is BallBody) {
      if (game.controls.isSoundEnabled) {
        final Vector2 velocity =
            body.linearVelocity - (other).body.linearVelocity;
        final double speed = velocity.length;

        if (speed > 0.1) {
          final volume = (speed * 0.5).clamp(0.1, 1.0);
          game.onCollision?.call(volume);
        }
      }
    }
  }
}

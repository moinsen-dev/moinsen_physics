import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Physics ball object that can be affected by gravity
class BallObject extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final double radius;
  final Color color;
  final double mass;
  final Function(double force) onCollision;
  
  BallObject({
    required this.position,
    required this.radius,
    required this.color,
    this.mass = 1.0,
    required this.onCollision,
  });
  
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: position,
      type: BodyType.dynamic,
    );
    
    final body = world.createBody(bodyDef);
    
    final shape = CircleShape()..radius = radius;
    
    final fixtureDef = FixtureDef(
      shape,
      density: mass / (radius * radius * 3.14159),
      friction: 0.3,
      restitution: 0.6, // Bounciness
    );
    
    body.createFixture(fixtureDef);
    
    return body;
  }
  
  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    
    // Calculate collision force
    final velocity = body.linearVelocity;
    final force = velocity.length / 100; // Normalize force
    
    onCollision(force.clamp(0.0, 1.0));
  }
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, radius, paint);
    
    // Add gradient for depth
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.transparent,
        ],
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
    
    canvas.drawCircle(Offset.zero, radius, gradientPaint);
    
    // Add border
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset.zero, radius, borderPaint);
  }
}
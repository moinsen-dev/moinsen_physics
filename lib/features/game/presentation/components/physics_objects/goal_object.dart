import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'ball_object.dart';

/// Goal zone where balls need to reach
class GoalObject extends BodyComponent with ContactCallbacks {
  @override
  final Vector2 position;
  final Vector2 size;
  final Function(BallObject ball) onBallEnter;
  final Function(BallObject ball) onBallExit;
  final Set<BallObject> ballsInside = {};
  
  GoalObject({
    required this.position,
    required this.size,
    required this.onBallEnter,
    required this.onBallExit,
  });
  
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static,
    );
    
    final body = world.createBody(bodyDef);
    
    final shape = PolygonShape()..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0);
    
    final fixtureDef = FixtureDef(
      shape,
      isSensor: true, // Make it a sensor so balls can pass through
    );
    
    body.createFixture(fixtureDef);
    
    return body;
  }
  
  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    
    if (other is BallObject && !ballsInside.contains(other)) {
      ballsInside.add(other);
      onBallEnter(other);
    }
  }
  
  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    
    if (other is BallObject && ballsInside.contains(other)) {
      ballsInside.remove(other);
      onBallExit(other);
    }
  }
  
  @override
  void render(Canvas canvas) {
    // Draw goal zone with animated effect
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x,
      height: size.y,
    );
    
    canvas.drawRect(rect, paint);
    
    // Add pulsing border
    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawRect(rect, borderPaint);
    
    // Draw success indicator if balls are inside
    if (ballsInside.isNotEmpty) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawRect(rect, glowPaint);
    }
    
    // Draw goal icon
    final iconPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw flag icon
    const flagSize = 20.0;
    final flagPath = Path()
      ..moveTo(0, -flagSize)
      ..lineTo(flagSize * 0.8, -flagSize * 0.7)
      ..lineTo(0, -flagSize * 0.4)
      ..lineTo(0, flagSize);
    
    canvas.drawPath(flagPath, iconPaint);
  }
}
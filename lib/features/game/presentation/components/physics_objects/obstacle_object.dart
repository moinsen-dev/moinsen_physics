import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Static or dynamic obstacle in the game world
class ObstacleObject extends BodyComponent {
  @override
  final Vector2 position;
  final Vector2 size;
  @override
  final double angle;
  final Color color;
  final bool isStatic;
  
  ObstacleObject({
    required this.position,
    required this.size,
    required this.angle,
    required this.color,
    this.isStatic = true,
  });
  
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: position,
      angle: angle,
      type: isStatic ? BodyType.static : BodyType.dynamic,
    );
    
    final body = world.createBody(bodyDef);
    
    final shape = PolygonShape()..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0);
    
    final fixtureDef = FixtureDef(
      shape,
      density: isStatic ? 0.0 : 2.0,
      friction: 0.5,
      restitution: 0.2,
    );
    
    body.createFixture(fixtureDef);
    
    return body;
  }
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x,
      height: size.y,
    );
    
    canvas.drawRect(rect, paint);
    
    // Add texture pattern
    final patternPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw diagonal lines for texture
    const spacing = 5.0;
    for (double i = -size.x; i < size.x; i += spacing) {
      canvas.drawLine(
        Offset(i, -size.y / 2),
        Offset(i + size.y, size.y / 2),
        patternPaint,
      );
    }
    
    // Add border
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRect(rect, borderPaint);
  }
}
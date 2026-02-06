import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Mind-blowing black hole with gravitational lensing effect
class BlackHoleComponent extends PositionComponent {
  final double radius;
  double eventHorizonRadius;
  final double maxForce;
  final Forge2DWorld world;
  
  late final CircleComponent eventHorizon;
  late final List<LensingRing> lensingRings;
  double rotationAngle = 0;
  
  // Particle system for accretion disk
  final List<AccretionParticle> accretionDisk = [];
  final Random random = Random();
  
  BlackHoleComponent({
    required Vector2 position,
    required this.world,
    this.radius = 150,
    this.eventHorizonRadius = 30,
    this.maxForce = 5000,
  }) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    // Create event horizon
    eventHorizon = CircleComponent(
      radius: eventHorizonRadius,
      paint: Paint()
        ..color = Colors.black
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10),
    );
    add(eventHorizon);
    
    // Create lensing rings
    lensingRings = List.generate(10, (i) {
      return LensingRing(
        radius: eventHorizonRadius + (i + 1) * 15,
        distortionStrength: 1.0 - (i * 0.1),
        color: Colors.purple.withValues(alpha: 0.3 - i * 0.03),
      );
    });
    
    for (final ring in lensingRings) {
      add(ring);
    }
    
    // Initialize accretion disk
    for (int i = 0; i < 200; i++) {
      accretionDisk.add(AccretionParticle(
        angle: random.nextDouble() * 2 * pi,
        distance: eventHorizonRadius + random.nextDouble() * 100,
        speed: random.nextDouble() * 2 + 1,
        size: random.nextDouble() * 3 + 1,
        color: _getAccretionColor(),
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    rotationAngle += dt * 0.5;
    
    // Apply gravitational force to all physics bodies
    for (final body in world.physicsWorld.bodies) {
      final distance = (body.position - position).length;
      
      if (distance < radius && distance > eventHorizonRadius) {
        // Calculate gravitational force (inverse square law)
        final direction = (position - body.position).normalized();
        final forceMagnitude = maxForce / (distance * distance / 100);
        
        body.applyForce(direction * forceMagnitude * body.mass);
        
        // Add rotational force for spiral effect
        final tangent = Vector2(-direction.y, direction.x);
        body.applyForce(tangent * forceMagnitude * 0.3 * body.mass);
      } else if (distance <= eventHorizonRadius) {
        // Object has crossed event horizon - destroy it!
        _consumeObject(body);
      }
    }
    
    // Update accretion disk
    _updateAccretionDisk(dt);
    
    // Update lensing effect
    for (int i = 0; i < lensingRings.length; i++) {
      lensingRings[i].phase = rotationAngle + i * 0.2;
    }
  }
  
  @override
  void render(Canvas canvas) {
    // Draw gravitational lensing effect
    canvas.save();
    canvas.translate(position.x, position.y);
    
    // Draw warped space grid
    _drawSpaceDistortion(canvas);
    
    // Draw accretion disk
    _drawAccretionDisk(canvas);
    
    canvas.restore();
    
    super.render(canvas);
    
    // Draw hawking radiation
    _drawHawkingRadiation(canvas);
  }
  
  void _drawSpaceDistortion(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Draw distorted grid lines
    const gridSize = 20.0;
    const gridCount = 20;
    
    for (int i = -gridCount; i <= gridCount; i++) {
      final points = <Offset>[];
      
      for (int j = -gridCount; j <= gridCount; j++) {
        final x = i * gridSize;
        final y = j * gridSize;
        final distance = sqrt(x * x + y * y);
        
        if (distance < radius) {
          // Apply gravitational lensing distortion
          final distortion = 1 - pow(distance / radius, 2);
          final factor = 1 + distortion * 0.5;
          final distortedX = x / factor;
          final distortedY = y / factor;
          
          points.add(Offset(distortedX, distortedY));
        } else {
          points.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
      
      // Draw horizontal lines
      paint.color = Colors.purple.withValues(alpha: 0.2);
      for (int k = 0; k < points.length - 1; k++) {
        canvas.drawLine(points[k], points[k + 1], paint);
      }
    }
  }
  
  void _drawAccretionDisk(Canvas canvas) {
    final paint = Paint()..blendMode = BlendMode.plus;
    
    for (final particle in accretionDisk) {
      final x = cos(particle.angle) * particle.distance;
      final y = sin(particle.angle) * particle.distance * 0.3; // Flatten for disk effect
      
      paint.color = particle.color.withValues(
        alpha: (1 - particle.distance / radius),
      );
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }
  
  void _drawHawkingRadiation(Canvas canvas) {
    final paint = Paint()
      ..blendMode = BlendMode.plus
      ..style = PaintingStyle.fill;
    
    // Draw radiation particles
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * pi + time;
      final distance = eventHorizonRadius + sin(time * 3 + i) * 5;
      
      final x = position.x + cos(angle) * distance;
      final y = position.y + sin(angle) * distance;
      
      paint.color = Colors.blueAccent.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }
  
  void _updateAccretionDisk(double dt) {
    for (final particle in accretionDisk) {
      // Spiral inward
      particle.distance -= dt * 10 / sqrt(particle.distance);
      particle.angle += dt * particle.speed / sqrt(particle.distance);
      
      // Reset particles that fall into black hole
      if (particle.distance <= eventHorizonRadius) {
        particle.distance = eventHorizonRadius + random.nextDouble() * 100;
        particle.angle = random.nextDouble() * 2 * pi;
        particle.color = _getAccretionColor();
      }
    }
  }
  
  void _consumeObject(Body body) {
    // Create dramatic consumption effect
    final consumptionEffect = BlackHoleConsumptionEffect(
      position: body.position,
      targetPosition: position,
      color: Colors.orange,
    );
    parent?.add(consumptionEffect);
    
    // Remove the body
    world.destroyBody(body);
    
    // Grow the black hole slightly
    eventHorizonRadius += 0.5;
    eventHorizon.radius = eventHorizonRadius;
  }
  
  Color _getAccretionColor() {
    final colors = [
      Colors.orange,
      Colors.red,
      Colors.yellow,
      Colors.white,
    ];
    return colors[random.nextInt(colors.length)];
  }
}

/// Lensing ring for gravitational distortion
class LensingRing extends PositionComponent {
  final double radius;
  final double distortionStrength;
  final Color color;
  double phase = 0;
  
  LensingRing({
    required this.radius,
    required this.distortionStrength,
    required this.color,
  });
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..blendMode = BlendMode.plus;
    
    // Draw distorted ring
    final path = Path();
    const segments = 60;
    
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;
      final distortion = sin(angle * 3 + phase) * distortionStrength * 10;
      final r = radius + distortion;
      
      final x = cos(angle) * r;
      final y = sin(angle) * r;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// Particle in the accretion disk
class AccretionParticle {
  double angle;
  double distance;
  double speed;
  double size;
  Color color;
  
  AccretionParticle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.size,
    required this.color,
  });
}

/// Consumption effect when objects fall into black hole
class BlackHoleConsumptionEffect extends PositionComponent with HasGameReference {
  final Vector2 targetPosition;
  final Color color;
  
  double lifetime = 1.0;
  double elapsed = 0;
  final List<ConsumptionParticle> particles = [];
  final Random random = Random();
  
  BlackHoleConsumptionEffect({
    required Vector2 position,
    required this.targetPosition,
    required this.color,
  }) : super(position: position) {
    // Create spiral particles
    for (int i = 0; i < 50; i++) {
      particles.add(ConsumptionParticle(
        angle: random.nextDouble() * 2 * pi,
        distance: random.nextDouble() * 30,
        speed: random.nextDouble() * 3 + 1,
      ));
    }
  }
  
  @override
  void update(double dt) {
    elapsed += dt;
    
    if (elapsed >= lifetime) {
      removeFromParent();
      return;
    }
    
    // Move towards black hole
    position = position + (targetPosition - position) * dt * 5;
    
    // Update particles
    for (final particle in particles) {
      particle.angle += dt * particle.speed;
      particle.distance *= (1 - dt * 2);
    }
  }
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..blendMode = BlendMode.plus;
    
    final progress = elapsed / lifetime;
    
    for (final particle in particles) {
      final x = position.x + cos(particle.angle) * particle.distance;
      final y = position.y + sin(particle.angle) * particle.distance;
      
      paint.color = color.withValues(alpha: (1 - progress) * 0.8);
      canvas.drawCircle(
        Offset(x, y),
        2 * (1 - progress),
        paint,
      );
    }
    
    // Draw light streaks
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + elapsed * 2;
      final startX = position.x + cos(angle) * 10;
      final startY = position.y + sin(angle) * 10;
      final endX = targetPosition.x;
      final endY = targetPosition.y;
      
      paint.color = Colors.white.withValues(alpha: (1 - progress) * 0.5);
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }
}

/// Particle for consumption effect
class ConsumptionParticle {
  double angle;
  double distance;
  double speed;
  
  ConsumptionParticle({
    required this.angle,
    required this.distance,
    required this.speed,
  });
}
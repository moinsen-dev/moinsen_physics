import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Quantum field visualization with probability waves and superposition effects
class QuantumFieldComponent extends PositionComponent {
  final double fieldRadius;
  final int waveCount;
  final Color primaryColor;
  final Color secondaryColor;
  
  double time = 0;
  final List<QuantumWave> waves = [];
  final List<QuantumParticle> quantumParticles = [];
  final Random random = Random();
  
  // Quantum foam visualization
  final List<FoamBubble> quantumFoam = [];
  
  QuantumFieldComponent({
    required Vector2 position,
    this.fieldRadius = 200,
    this.waveCount = 5,
    this.primaryColor = Colors.cyan,
    this.secondaryColor = Colors.purple,
  }) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    // Initialize quantum waves
    for (int i = 0; i < waveCount; i++) {
      waves.add(QuantumWave(
        frequency: 0.5 + random.nextDouble() * 2,
        amplitude: 20 + random.nextDouble() * 30,
        phase: random.nextDouble() * 2 * pi,
        color: Color.lerp(primaryColor, secondaryColor, i / waveCount)!,
      ));
    }
    
    // Initialize quantum particles
    for (int i = 0; i < 100; i++) {
      quantumParticles.add(QuantumParticle(
        position: Vector2(
          (random.nextDouble() - 0.5) * fieldRadius * 2,
          (random.nextDouble() - 0.5) * fieldRadius * 2,
        ),
        momentum: Vector2(
          (random.nextDouble() - 0.5) * 50,
          (random.nextDouble() - 0.5) * 50,
        ),
        spin: random.nextDouble() * 2 * pi,
      ));
    }
    
    // Initialize quantum foam
    for (int i = 0; i < 50; i++) {
      quantumFoam.add(FoamBubble(
        position: Vector2(
          (random.nextDouble() - 0.5) * fieldRadius * 2,
          (random.nextDouble() - 0.5) * fieldRadius * 2,
        ),
        radius: random.nextDouble() * 5 + 2,
        lifetime: random.nextDouble() * 2 + 1,
      ));
    }
  }
  
  @override
  void update(double dt) {
    time += dt;
    
    // Update quantum particles
    for (final particle in quantumParticles) {
      // Heisenberg uncertainty principle visualization
      particle.uncertaintyX = sin(time * 2 + particle.spin) * 5;
      particle.uncertaintyY = cos(time * 2 + particle.spin) * 5;
      
      // Quantum tunneling effect
      if (random.nextDouble() < 0.001) {
        particle.position = Vector2(
          (random.nextDouble() - 0.5) * fieldRadius * 2,
          (random.nextDouble() - 0.5) * fieldRadius * 2,
        );
      }
      
      // Wave function collapse visualization
      particle.collapsed = random.nextDouble() < 0.01;
      if (particle.collapsed) {
        particle.collapseTime = time;
      }
      
      // Update position based on momentum
      particle.position += particle.momentum * dt;
      
      // Boundary conditions (infinite potential well)
      if (particle.position.length > fieldRadius) {
        particle.momentum = -particle.momentum;
        particle.position = particle.position.normalized() * fieldRadius;
      }
    }
    
    // Update quantum foam
    for (final bubble in quantumFoam) {
      bubble.age += dt;
      
      // Replace expired bubbles
      if (bubble.age > bubble.lifetime) {
        bubble.position = Vector2(
          (random.nextDouble() - 0.5) * fieldRadius * 2,
          (random.nextDouble() - 0.5) * fieldRadius * 2,
        );
        bubble.age = 0;
        bubble.lifetime = random.nextDouble() * 2 + 1;
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.x, position.y);
    
    // Draw quantum field boundary
    _drawFieldBoundary(canvas);
    
    // Draw probability waves
    _drawProbabilityWaves(canvas);
    
    // Draw quantum foam
    _drawQuantumFoam(canvas);
    
    // Draw quantum particles
    _drawQuantumParticles(canvas);
    
    // Draw interference patterns
    _drawInterferencePattern(canvas);
    
    canvas.restore();
  }
  
  void _drawFieldBoundary(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = primaryColor.withValues(alpha: 0.3);
    
    // Pulsating boundary
    final pulseRadius = fieldRadius + sin(time * 2) * 10;
    
    canvas.drawCircle(Offset.zero, pulseRadius, paint);
    
    // Energy field gradient
    final gradient = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: 0.1),
        primaryColor.withValues(alpha: 0.0),
      ],
      stops: [0.7, 1.0],
    );
    
    paint.style = PaintingStyle.fill;
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: Offset.zero, radius: fieldRadius),
    );
    
    canvas.drawCircle(Offset.zero, fieldRadius, paint);
  }
  
  void _drawProbabilityWaves(Canvas canvas) {
    for (final wave in waves) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = wave.color.withValues(alpha: 0.5)
        ..blendMode = BlendMode.plus;
      
      final path = Path();
      const segments = 100;
      
      for (int i = 0; i <= segments; i++) {
        final angle = (i / segments) * 2 * pi;
        final waveValue = sin(angle * wave.frequency + time + wave.phase) * wave.amplitude;
        final r = fieldRadius * 0.7 + waveValue;
        
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
  
  void _drawQuantumFoam(Canvas canvas) {
    final paint = Paint()
      ..blendMode = BlendMode.plus;
    
    for (final bubble in quantumFoam) {
      final progress = bubble.age / bubble.lifetime;
      final alpha = sin(progress * pi) * 0.3;
      
      paint.color = secondaryColor.withValues(alpha: alpha);
      
      canvas.drawCircle(
        bubble.position.toOffset(),
        bubble.radius * (1 + progress * 0.5),
        paint,
      );
    }
  }
  
  void _drawQuantumParticles(Canvas canvas) {
    final paint = Paint()
      ..blendMode = BlendMode.plus;
    
    for (final particle in quantumParticles) {
      // Draw uncertainty cloud
      if (!particle.collapsed) {
        paint.color = primaryColor.withValues(alpha: 0.2);
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 5);
        
        canvas.drawCircle(
          particle.position.toOffset(),
          10,
          paint,
        );
      }
      
      // Draw particle
      paint.maskFilter = null;
      
      if (particle.collapsed) {
        // Collapsed wave function - definite position
        final timeSinceCollapse = time - particle.collapseTime;
        final alpha = max(0, 1 - timeSinceCollapse).toDouble();
        
        paint.color = Colors.white.withValues(alpha: alpha);
        canvas.drawCircle(
          particle.position.toOffset(),
          3,
          paint,
        );
        
        // Collapse flash
        if (timeSinceCollapse < 0.2) {
          paint.color = Colors.white.withValues(alpha: (1 - timeSinceCollapse * 5) * 0.5);
          canvas.drawCircle(
            particle.position.toOffset(),
            20 * timeSinceCollapse,
            paint,
          );
        }
      } else {
        // Superposition state
        paint.color = primaryColor.withValues(alpha: 0.6);
        
        // Draw probability positions
        for (int i = 0; i < 3; i++) {
          final offset = Vector2(
            particle.uncertaintyX * sin(time * 3 + i * 2 * pi / 3),
            particle.uncertaintyY * cos(time * 3 + i * 2 * pi / 3),
          );
          
          canvas.drawCircle(
            (particle.position + offset).toOffset(),
            2,
            paint,
          );
        }
      }
    }
  }
  
  void _drawInterferencePattern(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..blendMode = BlendMode.plus;
    
    // Draw interference rings
    for (int i = 0; i < 10; i++) {
      final radius = i * 20.0;
      final alpha = 0.1 * (1 - i / 10) * sin(time + i);
      
      paint.color = secondaryColor.withValues(alpha: alpha.abs());
      canvas.drawCircle(Offset.zero, radius, paint);
    }
  }
  
  /// Apply quantum effects to nearby physics bodies
  void applyQuantumEffects(Forge2DWorld world) {
    for (final body in world.physicsWorld.bodies) {
      final distance = (body.position - position).length;
      
      if (distance < fieldRadius) {
        // Quantum fluctuation forces
        final fluctuation = Vector2(
          (random.nextDouble() - 0.5) * 10,
          (random.nextDouble() - 0.5) * 10,
        );
        
        body.applyForce(fluctuation * body.mass);
        
        // Probability of quantum tunneling
        if (random.nextDouble() < 0.0001) {
          final tunnelDistance = 50.0;
          final tunnelDirection = Vector2(
            random.nextDouble() - 0.5,
            random.nextDouble() - 0.5,
          ).normalized();
          
          body.setTransform(
            body.position + tunnelDirection * tunnelDistance,
            body.angle,
          );
          
          // Visual effect for tunneling
          if (parent != null) {
            parent!.add(QuantumTunnelEffect(
              startPosition: body.position - tunnelDirection * tunnelDistance,
              endPosition: body.position,
              color: primaryColor,
            ));
          }
        }
      }
    }
  }
}

/// Individual quantum wave
class QuantumWave {
  final double frequency;
  final double amplitude;
  final double phase;
  final Color color;
  
  QuantumWave({
    required this.frequency,
    required this.amplitude,
    required this.phase,
    required this.color,
  });
}

/// Quantum particle with uncertainty
class QuantumParticle {
  Vector2 position;
  Vector2 momentum;
  double spin;
  double uncertaintyX = 0;
  double uncertaintyY = 0;
  bool collapsed = false;
  double collapseTime = 0;
  
  QuantumParticle({
    required this.position,
    required this.momentum,
    required this.spin,
  });
}

/// Quantum foam bubble
class FoamBubble {
  Vector2 position;
  double radius;
  double lifetime;
  double age = 0;
  
  FoamBubble({
    required this.position,
    required this.radius,
    required this.lifetime,
  });
}

/// Quantum tunnel effect visualization
class QuantumTunnelEffect extends PositionComponent {
  final Vector2 startPosition;
  final Vector2 endPosition;
  final Color color;
  
  double lifetime = 0.5;
  double elapsed = 0;
  
  QuantumTunnelEffect({
    required this.startPosition,
    required this.endPosition,
    required this.color,
  }) : super(position: startPosition);
  
  @override
  void update(double dt) {
    elapsed += dt;
    
    if (elapsed >= lifetime) {
      removeFromParent();
    }
  }
  
  @override
  void render(Canvas canvas) {
    final progress = elapsed / lifetime;
    final alpha = 1 - progress;
    
    final paint = Paint()
      ..color = color.withValues(alpha: alpha * 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.plus;
    
    // Draw quantum tunnel path
    final path = Path();
    path.moveTo(startPosition.x, startPosition.y);
    
    // Create wavy path
    const segments = 20;
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final baseX = startPosition.x + (endPosition.x - startPosition.x) * t;
      final baseY = startPosition.y + (endPosition.y - startPosition.y) * t;
      
      final wave = sin(t * pi * 4 + elapsed * 10) * 10 * (1 - progress);
      final normal = (endPosition - startPosition).normalized();
      final perpendicular = Vector2(-normal.y, normal.x);
      
      final x = baseX + perpendicular.x * wave;
      final y = baseY + perpendicular.y * wave;
      
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
    
    // Draw particle flash at endpoints
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withValues(alpha: alpha);
    
    canvas.drawCircle(startPosition.toOffset(), 5 * (1 - progress), paint);
    canvas.drawCircle(endPosition.toOffset(), 5 * progress, paint);
  }
}
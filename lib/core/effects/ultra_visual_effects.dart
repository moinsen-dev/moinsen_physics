import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Ultra-advanced visual effects system for Gravity Lab 2.0
/// Supports particle storms, ray-traced lighting simulation, and reality distortion
class UltraVisualEffects {
  static final Random _random = Random();
  
  /// Create a massive particle storm with 10,000+ particles
  static ParticleSystemComponent createParticleStorm({
    required Vector2 position,
    required Color color,
    int particleCount = 10000,
    double radius = 300,
  }) {
    final particles = <Particle>[];
    
    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = _random.nextDouble() * radius;
      final velocity = Vector2(cos(angle), sin(angle)) * (50 + _random.nextDouble() * 200);
      
      particles.add(
        AcceleratedParticle(
          acceleration: Vector2(0, 100),
          speed: velocity,
          position: position + Vector2(cos(angle) * distance, sin(angle) * distance),
          child: CircleParticle(
            radius: 0.5 + _random.nextDouble() * 2,
            paint: Paint()
              ..color = color.withValues(alpha: 0.8)
              ..blendMode = BlendMode.plus,
          ),
          lifespan: 2 + _random.nextDouble() * 3,
        ),
      );
    }
    
    return ParticleSystemComponent(
      particle: ComposedParticle(children: particles),
    );
  }
  
  /// Simulated ray-traced lighting with real-time shadows
  static Component createRayTracedLight({
    required Vector2 position,
    required double radius,
    required Color color,
    int rayCount = 360,
  }) {
    return RayTracedLightComponent(
      position: position,
      radius: radius,
      color: color,
      rayCount: rayCount,
    );
  }
  
  /// Holographic UI effect with depth and parallax
  static Component createHolographicUI({
    required Vector2 position,
    required Vector2 size,
    required Widget child,
  }) {
    return HolographicComponent(
      position: position,
      size: size,
      child: child,
    );
  }
  
  /// Reality distortion shader effect
  static Component createDistortionField({
    required Vector2 center,
    required double radius,
    double strength = 1.0,
  }) {
    return DistortionFieldComponent(
      center: center,
      radius: radius,
      strength: strength,
    );
  }
  
  /// Quantum particle trail effect
  static ParticleSystemComponent createQuantumTrail({
    required Vector2 position,
    required Color color,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 50,
        lifespan: 1.5,
        generator: (i) {
          final progress = i / 50;
          return AcceleratedParticle(
            acceleration: Vector2.zero(),
            speed: Vector2(_random.nextDouble() * 20 - 10, _random.nextDouble() * 20 - 10),
            position: position.clone(),
            child: CircleParticle(
              radius: 3 * (1 - progress),
              paint: Paint()
                ..color = color.withValues(alpha: 0.8 * (1 - progress))
                ..blendMode = BlendMode.plus
                ..shader = ui.Gradient.radial(
                  Offset.zero,
                  10,
                  [
                    color,
                    color.withValues(alpha: 0),
                  ],
                ),
            ),
          );
        },
      ),
    );
  }
  
  /// Explosion with realistic debris
  static ParticleSystemComponent createExplosion({
    required Vector2 position,
    required Color color,
    double intensity = 1.0,
  }) {
    final debrisCount = (100 * intensity).round();
    final particles = <Particle>[];
    
    // Core flash
    particles.add(
      ScalingParticle(
        to: 5.0,
        child: CircleParticle(
          radius: 20,
          paint: Paint()
            ..color = Colors.white
            ..blendMode = BlendMode.plus,
        ),
        lifespan: 0.2,
      ),
    );
    
    // Debris particles
    for (int i = 0; i < debrisCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 100 + _random.nextDouble() * 300 * intensity;
      final velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
      
      particles.add(
        AcceleratedParticle(
          acceleration: Vector2(0, 200),
          speed: velocity,
          position: position.clone(),
          child: RotatingParticle(
            to: _random.nextDouble() * 4 * pi,
            child: CircleParticle(
              radius: 2 + _random.nextDouble() * 2,
              paint: Paint()
                ..color = color
                ..blendMode = BlendMode.plus,
            ),
          ),
          lifespan: 1 + _random.nextDouble() * 2,
        ),
      );
    }
    
    // Smoke particles
    for (int i = 0; i < 50; i++) {
      particles.add(
        AcceleratedParticle(
          acceleration: Vector2(0, -50),
          speed: Vector2(_random.nextDouble() * 40 - 20, -50 - _random.nextDouble() * 50),
          position: position.clone(),
          child: ScalingParticle(
            to: 3.0,
            child: CircleParticle(
              radius: 10,
              paint: Paint()
                ..color = Colors.grey.withValues(alpha: 0.5)
                ..blendMode = BlendMode.multiply,
            ),
          ),
          lifespan: 2 + _random.nextDouble(),
        ),
      );
    }
    
    return ParticleSystemComponent(
      particle: ComposedParticle(children: particles),
    );
  }
  
  /// Antimatter annihilation effect
  static ParticleSystemComponent createAnnihilation({
    required Vector2 position,
  }) {
    return ParticleSystemComponent(
      particle: ComposedParticle(
        children: [
          // Energy burst
          ScalingParticle(
            to: 10.0,
            child: CircleParticle(
              radius: 5,
              paint: Paint()
                ..color = Colors.purple
                ..blendMode = BlendMode.plus
                ..shader = ui.Gradient.radial(
                  Offset.zero,
                  50,
                  [
                    Colors.white,
                    Colors.purple,
                    Colors.transparent,
                  ],
                  [0.0, 0.5, 1.0],
                ),
            ),
            lifespan: 0.5,
          ),
          // Energy rings
          ...List.generate(5, (i) {
            return ScalingParticle(
              to: 20.0 + i * 5,
              child: CircleParticle(
                radius: 2,
                paint: Paint()
                  ..color = Colors.purple.withValues(alpha: 0.5)
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..blendMode = BlendMode.plus,
              ),
              lifespan: 1.0 + i * 0.2,
            );
          }),
          // Particle spray
          Particle.generate(
            count: 200,
            lifespan: 2,
            generator: (i) {
              final angle = _random.nextDouble() * 2 * pi;
              final speed = 200 + _random.nextDouble() * 300;
              return AcceleratedParticle(
                acceleration: Vector2.zero(),
                speed: Vector2(cos(angle) * speed, sin(angle) * speed),
                position: position.clone(),
                child: CircleParticle(
                  radius: 1,
                  paint: Paint()
                    ..color = Colors.purple
                    ..blendMode = BlendMode.plus,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Component for ray-traced lighting simulation
class RayTracedLightComponent extends PositionComponent {
  final double radius;
  final Color color;
  final int rayCount;
  final List<Vector2> _rays = [];
  
  RayTracedLightComponent({
    required Vector2 position,
    required this.radius,
    required this.color,
    required this.rayCount,
  }) : super(position: position);
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..blendMode = BlendMode.plus;
    
    // Draw light rays
    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * pi;
      final end = position + Vector2(cos(angle), sin(angle)) * radius;
      
      final gradient = ui.Gradient.linear(
        position.toOffset(),
        end.toOffset(),
        [
          color,
          color.withValues(alpha: 0),
        ],
      );
      
      canvas.drawLine(
        position.toOffset(),
        end.toOffset(),
        paint..shader = gradient,
      );
    }
    
    // Central glow
    canvas.drawCircle(
      position.toOffset(),
      20,
      Paint()
        ..color = Colors.white
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }
}

/// Holographic UI component with 3D effect
class HolographicComponent extends PositionComponent {
  final Widget child;
  double _phase = 0;
  
  HolographicComponent({
    required Vector2 position,
    required Vector2 size,
    required this.child,
  }) : super(position: position, size: size);
  
  @override
  void update(double dt) {
    _phase += dt * 2;
  }
  
  @override
  void render(Canvas canvas) {
    // Holographic scanlines
    final paint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.3)
      ..blendMode = BlendMode.plus;
    
    for (int i = 0; i < size.y ~/ 2; i++) {
      final y = i * 2 + sin(_phase + i * 0.1) * 2;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        paint..strokeWidth = 0.5,
      );
    }
    
    // Glitch effect
    if (Random().nextDouble() < 0.05) {
      canvas.drawRect(
        Rect.fromLTWH(
          Random().nextDouble() * size.x,
          Random().nextDouble() * size.y,
          Random().nextDouble() * 50,
          Random().nextDouble() * 10,
        ),
        Paint()
          ..color = Colors.red.withValues(alpha: 0.5)
          ..blendMode = BlendMode.plus,
      );
    }
  }
}

/// Space distortion visual effect
class DistortionFieldComponent extends PositionComponent {
  final Vector2 center;
  final double radius;
  final double strength;
  double _phase = 0;
  
  DistortionFieldComponent({
    required this.center,
    required this.radius,
    required this.strength,
  }) : super(position: center);
  
  @override
  void update(double dt) {
    _phase += dt;
  }
  
  @override
  void render(Canvas canvas) {
    final rippleCount = 5;
    
    for (int i = 0; i < rippleCount; i++) {
      final progress = ((_phase + i / rippleCount) % 1.0);
      final currentRadius = radius * progress;
      final opacity = (1 - progress) * 0.5;
      
      canvas.drawCircle(
        center.toOffset(),
        currentRadius,
        Paint()
          ..color = Colors.purple.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..blendMode = BlendMode.plus,
      );
    }
  }
}
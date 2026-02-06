import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'haptic_manager.dart';

/// Juice effects manager - makes everything feel AMAZING!
class JuiceEffects {
  static final JuiceEffects _instance = JuiceEffects._internal();
  factory JuiceEffects() => _instance;
  JuiceEffects._internal();
  
  // Configuration
  bool _isEnabled = true;
  double _intensity = 1.0;
  
  // Screen shake
  Vector2 _shakeOffset = Vector2.zero();
  double _shakeIntensity = 0.0;
  double _shakeDecay = 0.95;
  
  bool get isEnabled => _isEnabled;
  double get intensity => _intensity;
  Vector2 get screenShakeOffset => _shakeOffset;
  
  void setEnabled(bool enabled) => _isEnabled = enabled;
  void setIntensity(double intensity) => _intensity = intensity.clamp(0.0, 2.0);
  
  /// Update juice effects (call every frame)
  void update(double dt) {
    if (!_isEnabled) return;
    
    // Update screen shake
    if (_shakeIntensity > 0.01) {
      _shakeOffset = Vector2(
        (math.Random().nextDouble() - 0.5) * _shakeIntensity,
        (math.Random().nextDouble() - 0.5) * _shakeIntensity,
      );
      _shakeIntensity *= _shakeDecay;
    } else {
      _shakeOffset = Vector2.zero();
      _shakeIntensity = 0;
    }
  }
  
  /// Trigger screen shake
  void screenShake({
    double intensity = 10.0,
    double decay = 0.95,
    bool withHaptic = true,
  }) {
    if (!_isEnabled) return;
    
    _shakeIntensity = intensity * _intensity;
    _shakeDecay = decay;
    
    if (withHaptic) {
      HapticManager.mediumImpact();
    }
  }
  
  /// Gravity switch effect
  Component gravitySwitch({
    required Vector2 position,
    required Vector2 oldGravity,
    required Vector2 newGravity,
  }) {
    if (!_isEnabled) return Component();
    
    // Calculate rotation angle
    final angle = math.atan2(newGravity.y, newGravity.x) - 
                  math.atan2(oldGravity.y, oldGravity.x);
    
    // Create effect container
    final container = PositionComponent(position: position);
    
    // Add rotation burst
    for (int i = 0; i < 12; i++) {
      final particleAngle = (i / 12) * math.pi * 2;
      container.add(_createGravityParticle(
        angle: particleAngle,
        speed: 100.0 + math.Random().nextDouble() * 50,
        color: HSLColor.fromAHSL(
          1.0,
          190 + math.Random().nextDouble() * 20, // Cyan-ish
          0.8,
          0.5 + math.Random().nextDouble() * 0.3,
        ).toColor(),
      ));
    }
    
    // Add shockwave
    container.add(_createShockwave());
    
    // Trigger haptic
    HapticManager.gravitySwitch();
    
    // Screen shake
    screenShake(intensity: 15.0, withHaptic: false);
    
    return container;
  }
  
  /// Object collision effect
  Component collision({
    required Vector2 position,
    required double force,
    Color? color1,
    Color? color2,
  }) {
    if (!_isEnabled) return Component();
    
    final container = PositionComponent(position: position);
    final particleCount = (force * 20).round().clamp(3, 30);
    
    // Collision particles
    for (int i = 0; i < particleCount; i++) {
      final angle = math.Random().nextDouble() * math.pi * 2;
      final speed = 50 + force * 100 + math.Random().nextDouble() * 50;
      final color = Color.lerp(
        color1 ?? Colors.white,
        color2 ?? Colors.yellow,
        math.Random().nextDouble(),
      )!;
      
      container.add(_createCollisionParticle(
        angle: angle,
        speed: speed,
        color: color,
        size: 2 + force * 3,
      ));
    }
    
    // Impact ring
    if (force > 0.5) {
      container.add(_createImpactRing(force: force));
    }
    
    // Screen shake based on force
    if (force > 0.3) {
      screenShake(
        intensity: force * 20,
        decay: 0.9,
        withHaptic: false,
      );
    }
    
    // Haptic feedback
    HapticManager.collision(force: force);
    
    return container;
  }
  
  /// Victory celebration effect
  Component victoryCelebration({
    required Vector2 position,
    required int stars,
  }) {
    if (!_isEnabled) return Component();
    
    final container = PositionComponent(position: position);
    
    // Fireworks based on stars
    for (int burst = 0; burst < stars; burst++) {
      Future.delayed(Duration(milliseconds: burst * 300), () {
        // Firework burst
        for (int i = 0; i < 30; i++) {
          final angle = (i / 30) * math.pi * 2;
          final speed = 150 + math.Random().nextDouble() * 100;
          final hue = math.Random().nextDouble() * 360;
          
          container.add(_createFireworkParticle(
            angle: angle,
            speed: speed,
            color: HSLColor.fromAHSL(1.0, hue, 0.8, 0.5).toColor(),
            delay: burst * 0.3,
          ));
        }
        
        // Star burst
        if (burst == stars - 1) {
          container.add(_createStarBurst(stars: stars));
        }
      });
    }
    
    // Victory haptic pattern
    HapticManager.victoryCelebration();
    
    // Epic screen shake
    screenShake(intensity: 25.0, decay: 0.98);
    
    return container;
  }
  
  /// Button press effect
  Component buttonPress({
    required Vector2 position,
    required Vector2 size,
    Color color = Colors.cyan,
  }) {
    if (!_isEnabled) return Component();
    
    final container = PositionComponent(position: position);
    
    // Ripple effect
    container.add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = color.withOpacity(0.3),
      )..add(
        ScaleEffect.to(
          Vector2.all(1.2),
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
      )..add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.2),
        ),
      ),
    );
    
    // Edge particles
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2;
      container.add(_createButtonParticle(
        startPos: Vector2(
          size.x / 2 + math.cos(angle) * size.x / 2,
          size.y / 2 + math.sin(angle) * size.y / 2,
        ),
        angle: angle,
        color: color,
      ));
    }
    
    HapticManager.buttonPress();
    
    return container;
  }
  
  /// Power-up collected effect
  Component powerUpCollected({
    required Vector2 position,
    required PowerUpType type,
  }) {
    if (!_isEnabled) return Component();
    
    final container = PositionComponent(position: position);
    final color = _getPowerUpColor(type);
    
    // Spiral particles
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * math.pi * 4; // Double spiral
      final delay = i * 0.02;
      
      container.add(_createSpiralParticle(
        angle: angle,
        radius: 30 + i * 2,
        color: color,
        delay: delay,
      ));
    }
    
    // Center flash
    container.add(_createFlash(color: color, size: 100));
    
    // Screen shake
    screenShake(intensity: 12.0);
    
    HapticManager.powerUpCollected();
    
    return container;
  }
  
  // Private helper methods
  
  Component _createGravityParticle({
    required double angle,
    required double speed,
    required Color color,
  }) {
    final velocity = Vector2(
      math.cos(angle) * speed,
      math.sin(angle) * speed,
    );
    
    return CircleComponent(
      radius: 3,
      paint: Paint()..color = color,
    )..add(
      MoveEffect.by(
        velocity,
        EffectController(duration: 0.8, curve: Curves.easeOut),
      ),
    )..add(
      OpacityEffect.fadeOut(
        EffectController(
          duration: 0.8,
          startDelay: 0.2,
          curve: Curves.easeIn,
        ),
      ),
    )..add(
      ScaleEffect.to(
        Vector2.all(0.2),
        EffectController(duration: 0.8, curve: Curves.easeOut),
      ),
    );
  }
  
  Component _createShockwave() {
    return CircleComponent(
      radius: 5,
      paint: Paint()
        ..color = Colors.cyan.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    )..add(
      ScaleEffect.to(
        Vector2.all(20),
        EffectController(duration: 0.5, curve: Curves.easeOut),
      ),
    )..add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5),
      ),
    );
  }
  
  Component _createCollisionParticle({
    required double angle,
    required double speed,
    required Color color,
    required double size,
  }) {
    final velocity = Vector2(
      math.cos(angle) * speed,
      math.sin(angle) * speed,
    );
    
    return CircleComponent(
      radius: size,
      paint: Paint()..color = color,
    )..add(
      MoveEffect.by(
        velocity,
        EffectController(duration: 0.6, curve: Curves.easeOut),
      ),
    )..add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.6, curve: Curves.easeIn),
      ),
    )..add(
      ScaleEffect.to(
        Vector2.all(0.1),
        EffectController(duration: 0.6),
      ),
    );
  }
  
  Component _createImpactRing({required double force}) {
    return CircleComponent(
      radius: 10,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    )..add(
      ScaleEffect.to(
        Vector2.all(5 + force * 5),
        EffectController(duration: 0.3, curve: Curves.easeOut),
      ),
    )..add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.3),
      ),
    );
  }
  
  Component _createFireworkParticle({
    required double angle,
    required double speed,
    required Color color,
    required double delay,
  }) {
    final velocity = Vector2(
      math.cos(angle) * speed,
      math.sin(angle) * speed,
    );
    
    // Add gravity effect
    final gravity = Vector2(0, 200);
    
    return CircleComponent(
      radius: 4,
      paint: Paint()..color = color,
    )..add(
      MoveByEffect(
        velocity,
        EffectController(
          duration: 1.5,
          startDelay: delay,
          curve: Curves.easeOut,
        ),
      ),
    )..add(
      MoveByEffect(
        gravity,
        EffectController(
          duration: 1.5,
          startDelay: delay,
          curve: Curves.easeIn,
        ),
      ),
    )..add(
      OpacityEffect.fadeOut(
        EffectController(
          duration: 1.5,
          startDelay: delay + 0.5,
        ),
      ),
    )..add(
      ScaleEffect.to(
        Vector2.all(0.2),
        EffectController(
          duration: 1.5,
          startDelay: delay,
        ),
      ),
    );
  }
  
  Component _createStarBurst({required int stars}) {
    final container = PositionComponent();
    
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2 - math.pi / 2;
      final distance = 80.0;
      
      container.add(
        SpriteComponent() // TODO: Add star sprite
          ..position = Vector2(
            math.cos(angle) * distance,
            math.sin(angle) * distance,
          )
          ..size = Vector2.all(40)
          ..anchor = Anchor.center
          ..add(
            RotateEffect.by(
              math.pi * 2,
              EffectController(duration: 1.0),
            ),
          )..add(
            ScaleEffect.to(
              Vector2.all(i < stars ? 1.5 : 0.5),
              EffectController(duration: 0.5, curve: Curves.elasticOut),
            ),
          ),
      );
    }
    
    return container;
  }
  
  Component _createButtonParticle({
    required Vector2 startPos,
    required double angle,
    required Color color,
  }) {
    return CircleComponent(
      radius: 2,
      position: startPos,
      paint: Paint()..color = color,
    )..add(
      MoveByEffect(
        Vector2(math.cos(angle) * 30, math.sin(angle) * 30),
        EffectController(duration: 0.3, curve: Curves.easeOut),
      ),
    )..add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.3),
      ),
    );
  }
  
  Component _createSpiralParticle({
    required double angle,
    required double radius,
    required Color color,
    required double delay,
  }) {
    final startPos = Vector2(
      math.cos(angle) * radius,
      math.sin(angle) * radius,
    );
    
    return CircleComponent(
      radius: 3,
      position: startPos,
      paint: Paint()..color = color,
    )..add(
      MoveToEffect(
        Vector2.zero(),
        EffectController(
          duration: 0.5,
          startDelay: delay,
          curve: Curves.easeInOut,
        ),
      ),
    )..add(
      OpacityEffect.fadeOut(
        EffectController(
          duration: 0.5,
          startDelay: delay + 0.2,
        ),
      ),
    )..add(
      ScaleEffect.to(
        Vector2.all(0.1),
        EffectController(
          duration: 0.5,
          startDelay: delay,
        ),
      ),
    );
  }
  
  Component _createFlash({
    required Color color,
    required double size,
  }) {
    return CircleComponent(
      radius: size / 2,
      paint: Paint()..color = color.withOpacity(0.8),
    )..add(
      ScaleEffect.to(
        Vector2.all(2),
        EffectController(duration: 0.2, curve: Curves.easeOut),
      ),
    )..add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.2),
      ),
    );
  }
  
  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.speed:
        return Colors.blue;
      case PowerUpType.slowMotion:
        return Colors.purple;
      case PowerUpType.magnet:
        return Colors.red;
      case PowerUpType.shield:
        return Colors.green;
      case PowerUpType.multiball:
        return Colors.orange;
      case PowerUpType.gravity:
        return Colors.cyan;
    }
  }
}

/// Power-up types for effects
enum PowerUpType {
  speed,
  slowMotion,
  magnet,
  shield,
  multiball,
  gravity,
}

/// Extension for easy juice integration
extension JuiceExtension on Component {
  /// Add juice to any component
  void addJuice(JuiceType type, {Map<String, dynamic>? params}) {
    final juice = JuiceEffects();
    
    switch (type) {
      case JuiceType.bounce:
        add(ScaleEffect.by(
          Vector2.all(1.2),
          EffectController(
            duration: 0.1,
            alternate: true,
            repeatCount: 1,
          ),
        ));
        break;
        
      case JuiceType.wobble:
        add(RotateEffect.by(
          0.1,
          EffectController(
            duration: 0.1,
            alternate: true,
            repeatCount: 3,
          ),
        ));
        break;
        
      case JuiceType.pulse:
        add(ScaleEffect.by(
          Vector2.all(1.1),
          EffectController(
            duration: 0.5,
            alternate: true,
            infinite: true,
          ),
        ));
        break;
        
      case JuiceType.flash:
        // TODO: Add color flash effect
        break;
    }
  }
}

enum JuiceType {
  bounce,
  wobble,
  pulse,
  flash,
}
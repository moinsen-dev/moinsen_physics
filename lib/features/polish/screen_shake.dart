import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'dart:math' as math;

/// Screen shake widget wrapper for Flutter
class ScreenShakeWidget extends StatefulWidget {
  final Widget child;
  final ScreenShakeController controller;
  
  const ScreenShakeWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ScreenShakeWidget> createState() => _ScreenShakeWidgetState();
}

class _ScreenShakeWidgetState extends State<ScreenShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Offset _shakeOffset = Offset.zero;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    widget.controller.addListener(_onShake);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_onShake);
    _animationController.dispose();
    super.dispose();
  }
  
  void _onShake() {
    if (widget.controller.isShaking) {
      _animationController.forward(from: 0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        if (widget.controller.isShaking) {
          _shakeOffset = Offset(
            widget.controller.offset.x,
            widget.controller.offset.y,
          );
        } else {
          _shakeOffset = Offset.zero;
        }
        
        return Transform.translate(
          offset: _shakeOffset,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Controller for screen shake effects
class ScreenShakeController extends ChangeNotifier {
  Vector2 _offset = Vector2.zero();
  double _intensity = 0.0;
  double _decay = 0.95;
  bool _isShaking = false;
  
  Vector2 get offset => _offset;
  bool get isShaking => _isShaking;
  
  /// Trigger a screen shake
  void shake({
    double intensity = 10.0,
    double decay = 0.95,
    ShakePattern pattern = ShakePattern.random,
  }) {
    _intensity = intensity;
    _decay = decay;
    _isShaking = true;
    notifyListeners();
  }
  
  /// Update shake (call every frame)
  void update(double dt) {
    if (!_isShaking || _intensity < 0.01) {
      _offset = Vector2.zero();
      _isShaking = false;
      return;
    }
    
    // Apply shake pattern
    _offset = _calculateShakeOffset(_intensity);
    
    // Decay intensity
    _intensity *= _decay;
    
    notifyListeners();
  }
  
  Vector2 _calculateShakeOffset(double intensity) {
    final random = math.Random();
    return Vector2(
      (random.nextDouble() - 0.5) * intensity * 2,
      (random.nextDouble() - 0.5) * intensity * 2,
    );
  }
  
  /// Stop shaking immediately
  void stop() {
    _intensity = 0;
    _offset = Vector2.zero();
    _isShaking = false;
    notifyListeners();
  }
}

/// Shake patterns for different effects
enum ShakePattern {
  random,
  horizontal,
  vertical,
  circular,
  earthquake,
}

/// Camera shake component for Flame games
class CameraShake extends Component with HasGameReference {
  final CameraComponent camera;
  Vector2 _originalPosition = Vector2.zero();
  Vector2 _shakeOffset = Vector2.zero();
  double _intensity = 0.0;
  double _decay = 0.95;
  double _frequency = 30.0;
  double _time = 0.0;
  ShakePattern _pattern = ShakePattern.random;
  bool _isShaking = false;
  
  CameraShake({required this.camera});
  
  @override
  void onMount() {
    super.onMount();
    _originalPosition = camera.viewfinder.position.clone();
  }
  
  /// Trigger camera shake
  void shake({
    double intensity = 10.0,
    double decay = 0.95,
    double frequency = 30.0,
    ShakePattern pattern = ShakePattern.random,
  }) {
    _intensity = intensity;
    _decay = decay;
    _frequency = frequency;
    _pattern = pattern;
    _isShaking = true;
    _time = 0.0;
  }
  
  /// Earthquake effect (long, low frequency shake)
  void earthquake({double intensity = 20.0}) {
    shake(
      intensity: intensity,
      decay: 0.98,
      frequency: 5.0,
      pattern: ShakePattern.earthquake,
    );
  }
  
  /// Impact shake (short, intense)
  void impact({double intensity = 15.0}) {
    shake(
      intensity: intensity,
      decay: 0.85,
      frequency: 50.0,
      pattern: ShakePattern.random,
    );
  }
  
  /// Explosion shake (very intense, quick decay)
  void explosion({double intensity = 30.0}) {
    shake(
      intensity: intensity,
      decay: 0.8,
      frequency: 60.0,
      pattern: ShakePattern.random,
    );
  }
  
  @override
  void update(double dt) {
    if (!_isShaking || _intensity < 0.01) {
      if (_isShaking) {
        // Reset camera position
        camera.viewfinder.position = _originalPosition.clone();
        _isShaking = false;
      }
      return;
    }
    
    _time += dt;
    
    // Calculate shake offset based on pattern
    _shakeOffset = _calculateOffset();
    
    // Apply shake to camera
    camera.viewfinder.position = _originalPosition + _shakeOffset;
    
    // Decay intensity
    _intensity *= _decay;
  }
  
  Vector2 _calculateOffset() {
    final random = math.Random();
    
    switch (_pattern) {
      case ShakePattern.random:
        return Vector2(
          (random.nextDouble() - 0.5) * _intensity * 2,
          (random.nextDouble() - 0.5) * _intensity * 2,
        );
        
      case ShakePattern.horizontal:
        return Vector2(
          math.sin(_time * _frequency) * _intensity,
          0,
        );
        
      case ShakePattern.vertical:
        return Vector2(
          0,
          math.sin(_time * _frequency) * _intensity,
        );
        
      case ShakePattern.circular:
        final angle = _time * _frequency;
        return Vector2(
          math.cos(angle) * _intensity,
          math.sin(angle) * _intensity,
        );
        
      case ShakePattern.earthquake:
        // Low frequency, multi-directional
        return Vector2(
          math.sin(_time * _frequency) * _intensity +
              math.sin(_time * _frequency * 1.5) * _intensity * 0.5,
          math.cos(_time * _frequency * 0.8) * _intensity * 0.7,
        );
    }
  }
  
  /// Stop shaking immediately
  void stop() {
    _isShaking = false;
    _intensity = 0;
    camera.viewfinder.position = _originalPosition.clone();
  }
}

/// Screen shake presets
class ShakePresets {
  // UI interactions
  static const buttonTap = ShakeConfig(intensity: 2, decay: 0.9, duration: 0.1);
  static const buttonError = ShakeConfig(intensity: 5, decay: 0.85, duration: 0.2);
  
  // Game events
  static const smallCollision = ShakeConfig(intensity: 5, decay: 0.9, duration: 0.2);
  static const mediumCollision = ShakeConfig(intensity: 10, decay: 0.9, duration: 0.3);
  static const bigCollision = ShakeConfig(intensity: 20, decay: 0.85, duration: 0.5);
  
  // Special effects
  static const explosion = ShakeConfig(intensity: 30, decay: 0.8, duration: 0.6);
  static const earthquake = ShakeConfig(intensity: 15, decay: 0.98, duration: 3.0);
  static const victory = ShakeConfig(intensity: 25, decay: 0.95, duration: 1.0);
  
  // Power-ups
  static const powerUpCollected = ShakeConfig(intensity: 8, decay: 0.9, duration: 0.3);
  static const powerUpActivated = ShakeConfig(intensity: 12, decay: 0.88, duration: 0.4);
}

/// Configuration for shake effects
class ShakeConfig {
  final double intensity;
  final double decay;
  final double duration;
  final ShakePattern pattern;
  
  const ShakeConfig({
    required this.intensity,
    required this.decay,
    required this.duration,
    this.pattern = ShakePattern.random,
  });
}
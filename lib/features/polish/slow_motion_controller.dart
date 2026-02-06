import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Controls slow motion effects in the game
class SlowMotionController extends ChangeNotifier {
  static final SlowMotionController _instance = SlowMotionController._internal();
  factory SlowMotionController() => _instance;
  SlowMotionController._internal();
  
  // Time scale (1.0 = normal, 0.5 = half speed, 0.1 = very slow)
  double _timeScale = 1.0;
  double _targetTimeScale = 1.0;
  double _transitionSpeed = 5.0;
  
  // Effects
  bool _isActive = false;
  double _duration = 0.0;
  double _elapsed = 0.0;
  SlowMotionCurve _curve = SlowMotionCurve.smooth;
  
  // Callbacks
  VoidCallback? _onComplete;
  
  double get timeScale => _timeScale;
  bool get isActive => _isActive;
  double get progress => _duration > 0 ? (_elapsed / _duration).clamp(0.0, 1.0) : 0.0;
  
  /// Update slow motion (call every frame)
  void update(double dt) {
    // Smooth transition to target time scale
    if ((_timeScale - _targetTimeScale).abs() > 0.01) {
      _timeScale = _lerp(_timeScale, _targetTimeScale, dt * _transitionSpeed);
      notifyListeners();
    }
    
    // Handle timed slow motion
    if (_isActive && _duration > 0) {
      _elapsed += dt;
      
      if (_elapsed >= _duration) {
        stop();
      } else {
        // Apply curve to time scale
        final curveProgress = _applyCurve(_elapsed / _duration);
        _targetTimeScale = _lerp(1.0, 0.1, curveProgress);
      }
    }
  }
  
  /// Start slow motion effect
  void start({
    double scale = 0.3,
    double duration = 0.0, // 0 = infinite
    double transitionSpeed = 5.0,
    SlowMotionCurve curve = SlowMotionCurve.smooth,
    VoidCallback? onComplete,
  }) {
    _targetTimeScale = scale.clamp(0.01, 1.0);
    _duration = duration;
    _elapsed = 0.0;
    _transitionSpeed = transitionSpeed;
    _curve = curve;
    _onComplete = onComplete;
    _isActive = true;
    
    notifyListeners();
  }
  
  /// Stop slow motion smoothly
  void stop() {
    _targetTimeScale = 1.0;
    _isActive = false;
    _duration = 0.0;
    _elapsed = 0.0;
    
    _onComplete?.call();
    _onComplete = null;
    
    notifyListeners();
  }
  
  /// Stop slow motion instantly
  void stopInstant() {
    _timeScale = 1.0;
    _targetTimeScale = 1.0;
    _isActive = false;
    _duration = 0.0;
    _elapsed = 0.0;
    
    _onComplete?.call();
    _onComplete = null;
    
    notifyListeners();
  }
  
  /// Victory slow motion effect
  void victory() {
    start(
      scale: 0.2,
      duration: 1.5,
      transitionSpeed: 3.0,
      curve: SlowMotionCurve.dramatic,
    );
  }
  
  /// Collision slow motion effect
  void collision({double force = 1.0}) {
    if (force > 0.7) {
      start(
        scale: 0.5,
        duration: 0.3,
        transitionSpeed: 10.0,
        curve: SlowMotionCurve.impact,
      );
    }
  }
  
  /// Power-up slow motion effect
  void powerUp() {
    start(
      scale: 0.6,
      duration: 2.0,
      transitionSpeed: 5.0,
      curve: SlowMotionCurve.smooth,
    );
  }
  
  /// Near miss slow motion effect
  void nearMiss() {
    start(
      scale: 0.4,
      duration: 0.5,
      transitionSpeed: 8.0,
      curve: SlowMotionCurve.quick,
    );
  }
  
  double _lerp(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }
  
  double _applyCurve(double t) {
    switch (_curve) {
      case SlowMotionCurve.linear:
        return t;
        
      case SlowMotionCurve.smooth:
        // Ease in-out
        return t < 0.5
            ? 2 * t * t
            : -1 + (4 - 2 * t) * t;
            
      case SlowMotionCurve.dramatic:
        // Quick in, slow middle, quick out
        if (t < 0.2) {
          return t * 5;
        } else if (t < 0.8) {
          return 1.0;
        } else {
          return 1.0 - (t - 0.8) * 5;
        }
        
      case SlowMotionCurve.impact:
        // Very quick in, hold, smooth out
        if (t < 0.1) {
          return t * 10;
        } else if (t < 0.6) {
          return 1.0;
        } else {
          final progress = (t - 0.6) / 0.4;
          return 1.0 - (progress * progress);
        }
        
      case SlowMotionCurve.quick:
        // Quick in and out
        return math.sin(t * math.pi);
    }
  }
}

/// Curves for slow motion effects
enum SlowMotionCurve {
  linear,
  smooth,
  dramatic,
  impact,
  quick,
}

/// Widget that applies slow motion to animations
class SlowMotionWidget extends StatefulWidget {
  final Widget child;
  final SlowMotionController? controller;
  final bool affectsAnimations;
  
  const SlowMotionWidget({
    super.key,
    required this.child,
    this.controller,
    this.affectsAnimations = true,
  });

  @override
  State<SlowMotionWidget> createState() => _SlowMotionWidgetState();
}

class _SlowMotionWidgetState extends State<SlowMotionWidget>
    with SingleTickerProviderStateMixin {
  late SlowMotionController _controller;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SlowMotionController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _controller.addListener(_onTimeScaleChanged);
  }
  
  @override
  void dispose() {
    _controller.removeListener(_onTimeScaleChanged);
    _animationController.dispose();
    super.dispose();
  }
  
  void _onTimeScaleChanged() {
    if (widget.affectsAnimations) {
      // Update animation speed
      _animationController.duration = Duration(
        milliseconds: (1000 / _controller.timeScale).round(),
      );
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Slow motion visual effects overlay
class SlowMotionOverlay extends StatelessWidget {
  final SlowMotionController controller;
  final Color color;
  final bool showVignette;
  final bool showMotionBlur;
  
  const SlowMotionOverlay({
    super.key,
    required this.controller,
    this.color = Colors.blue,
    this.showVignette = true,
    this.showMotionBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (!controller.isActive) {
          return const SizedBox.shrink();
        }
        
        final opacity = (1.0 - controller.timeScale) * 0.3;
        
        return IgnorePointer(
          child: Stack(
            children: [
              // Color overlay
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(opacity * 0.2),
                ),
              ),
              
              // Vignette effect
              if (showVignette)
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(opacity * 0.5),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              
              // Motion blur lines (simplified)
              if (showMotionBlur && controller.timeScale < 0.5)
                CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: MotionBlurPainter(
                    intensity: 1.0 - controller.timeScale,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Simple motion blur effect painter
class MotionBlurPainter extends CustomPainter {
  final double intensity;
  
  MotionBlurPainter({required this.intensity});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(intensity * 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw horizontal speed lines
    final lineCount = (intensity * 20).round();
    final random = math.Random(42); // Fixed seed for consistency
    
    for (int i = 0; i < lineCount; i++) {
      final y = random.nextDouble() * size.height;
      final startX = random.nextDouble() * size.width * 0.3;
      final length = size.width * (0.3 + random.nextDouble() * 0.4);
      
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + length, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(MotionBlurPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}
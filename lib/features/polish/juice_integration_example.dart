import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'juice_effects.dart';
import 'screen_shake.dart';
import 'slow_motion_controller.dart';
import 'haptic_manager.dart';

/// Example of how to integrate all juice effects into a game
class JuicedGameExample extends Forge2DGame {
  late final JuiceEffects juice;
  late final CameraShake cameraShake;
  late final SlowMotionController slowMotion;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize juice systems
    juice = JuiceEffects();
    slowMotion = SlowMotionController();
    cameraShake = CameraShake(camera: camera);
    
    add(cameraShake);
    
    // Example: Add a gravity switch button
    add(
      GravitySwitchButton(
        position: Vector2(100, 100),
        onPressed: () => _onGravitySwitch(),
      ),
    );
  }
  
  @override
  void update(double dt) {
    // Apply slow motion to delta time
    final scaledDt = dt * slowMotion.timeScale;
    
    // Update juice effects
    juice.update(scaledDt);
    slowMotion.update(dt); // This uses real dt
    cameraShake.update(dt);
    
    // Use scaledDt for game logic
    super.update(scaledDt);
  }
  
  void _onGravitySwitch() {
    // Get current gravity
    final oldGravity = world.gravity;
    final newGravity = Vector2(0, -world.gravity.y); // Flip gravity
    
    // Update physics
    world.gravity = newGravity;
    
    // Add juice!
    add(juice.gravitySwitch(
      position: size / 2,
      oldGravity: oldGravity,
      newGravity: newGravity,
    ));
    
    // Slow motion for dramatic effect
    slowMotion.start(
      scale: 0.3,
      duration: 0.5,
      curve: SlowMotionCurve.dramatic,
    );
  }
  
  void _onCollision(Body bodyA, Body bodyB, double force) {
    // Calculate collision point
    final contactPoint = (bodyA.position + bodyB.position) / 2;
    
    // Add collision effect
    add(juice.collision(
      position: contactPoint,
      force: force,
      color1: Colors.orange,
      color2: Colors.yellow,
    ));
    
    // Camera shake based on force
    if (force > 0.5) {
      cameraShake.impact(intensity: force * 20);
    }
    
    // Slow motion for big impacts
    if (force > 0.8) {
      slowMotion.collision(force: force);
    }
  }
  
  void _onVictory(int stars) {
    // Victory effects
    add(juice.victoryCelebration(
      position: size / 2,
      stars: stars,
    ));
    
    // Epic slow motion
    slowMotion.victory();
    
    // Victory shake
    cameraShake.shake(
      intensity: 25,
      pattern: ShakePattern.circular,
    );
  }
  
  void _onPowerUpCollected(PowerUpType type, Vector2 position) {
    // Power-up effect
    add(juice.powerUpCollected(
      position: position,
      type: type,
    ));
    
    // Slow motion burst
    slowMotion.powerUp();
    
    // Gentle shake
    cameraShake.shake(
      intensity: 8,
      decay: 0.9,
    );
  }
}

/// Example gravity switch button with juice
class GravitySwitchButton extends PositionComponent {
  final VoidCallback onPressed;
  bool _isPressed = false;
  
  GravitySwitchButton({
    required Vector2 position,
    required this.onPressed,
  }) : super(position: position, size: Vector2.all(80));
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = _isPressed 
          ? Colors.cyan.withValues(alpha: 0.8) 
          : Colors.cyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
    
    // Draw arrow
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final path = Path()
      ..moveTo(size.x / 2, size.y * 0.2)
      ..lineTo(size.x / 2, size.y * 0.8)
      ..moveTo(size.x * 0.3, size.y * 0.6)
      ..lineTo(size.x / 2, size.y * 0.8)
      ..lineTo(size.x * 0.7, size.y * 0.6);
    
    canvas.drawPath(path, arrowPaint);
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    _isPressed = true;
    
    // Add button press juice
    final juice = JuiceEffects();
    parent?.add(juice.buttonPress(
      position: position,
      size: size,
      color: Colors.cyan,
    ));
    
    // Haptic feedback
    HapticManager.buttonPress();
    
    // Add bounce animation
    addJuice(JuiceType.bounce);
    
    // Call the callback
    onPressed();
    
    return true;
  }
  
  @override
  bool onTapUp(TapUpEvent event) {
    _isPressed = false;
    return true;
  }
}

/// Example game screen with juice integration
class JuicedGameScreen extends StatefulWidget {
  const JuicedGameScreen({super.key});

  @override
  State<JuicedGameScreen> createState() => _JuicedGameScreenState();
}

class _JuicedGameScreenState extends State<JuicedGameScreen> {
  late final JuicedGameExample game;
  late final ScreenShakeController shakeController;
  late final SlowMotionController slowMotionController;
  
  @override
  void initState() {
    super.initState();
    game = JuicedGameExample();
    shakeController = ScreenShakeController();
    slowMotionController = SlowMotionController();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game with screen shake
          ScreenShakeWidget(
            controller: shakeController,
            child: GameWidget(game: game),
          ),
          
          // Slow motion overlay
          SlowMotionOverlay(
            controller: slowMotionController,
            color: Colors.purple,
            showVignette: true,
            showMotionBlur: true,
          ),
          
          // UI with haptic feedback
          Positioned(
            bottom: 50,
            right: 50,
            child: FloatingActionButton(
              onPressed: () {
                HapticManager.heavyImpact();
                game._onVictory(3);
              },
              backgroundColor: Colors.yellow,
              child: const Icon(Icons.star, color: Colors.black),
            ).withHaptic(pattern: HapticPattern.celebration),
          ),
        ],
      ),
    );
  }
}

/// Tips for maximum juice:
/// 
/// 1. LAYER EFFECTS:
///    - Combine visual + audio + haptic for every action
///    - Use screen shake sparingly but effectively
///    - Add particle effects to everything
/// 
/// 2. TIMING IS KEY:
///    - Use slow motion for dramatic moments
///    - Delay effects slightly for anticipation
///    - Chain effects for maximum impact
/// 
/// 3. FEEDBACK HIERARCHY:
///    - Small actions = subtle feedback
///    - Big actions = dramatic feedback
///    - Victory = ALL THE JUICE!
/// 
/// 4. PERFORMANCE:
///    - Pool particle objects
///    - Limit simultaneous effects
///    - Provide quality settings
/// 
/// 5. ACCESSIBILITY:
///    - Allow disabling screen shake
///    - Provide reduced motion option
///    - Keep essential feedback visible
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/physics/quantum_physics_engine.dart';
import '../../../../core/effects/ultra_visual_effects.dart';
import '../../domain/entities/quantum_game_object.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Revolutionary gameplay screen for Gravity Lab 2.0
class QuantumGameplayScreen extends StatefulWidget {
  const QuantumGameplayScreen({super.key});

  @override
  State<QuantumGameplayScreen> createState() => _QuantumGameplayScreenState();
}

class _QuantumGameplayScreenState extends State<QuantumGameplayScreen> {
  late final QuantumGravityGame game;
  
  @override
  void initState() {
    super.initState();
    game = QuantumGravityGame();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game view
          GameWidget(game: game),
          
          // HUD Overlay
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _buildHUD(),
          ),
          
          // Reality-bending controls
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildQuantumControls(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUANTUM LEVEL 1',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Reality Distortion: ACTIVE',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          // Time display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'TIME: 2:47',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'QUANTUM SCORE',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 12,
                ),
              ),
              Text(
                '42,000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuantumControls() {
    return Container(
      height: 120,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.replay,
            label: 'REWIND',
            color: Colors.blue,
            onPressed: () => game.rewindTime(2.0),
          ),
          _buildControlButton(
            icon: Icons.blur_on,
            label: 'QUANTUM',
            color: Colors.purple,
            onPressed: () => game.toggleQuantumMode(),
          ),
          _buildControlButton(
            icon: Icons.explore,
            label: 'GRAVITY',
            color: Colors.green,
            onPressed: () => game.paintGravityMode(),
          ),
          _buildControlButton(
            icon: Icons.flash_on,
            label: 'ENERGY',
            color: Colors.yellow,
            onPressed: () => game.activateEnergyBurst(),
          ),
          _buildControlButton(
            icon: Icons.space_dashboard,
            label: 'PORTAL',
            color: Colors.cyan,
            onPressed: () => game.createPortalMode(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: 60,
        height: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The revolutionary game engine
class QuantumGravityGame extends Forge2DGame with TapCallbacks {
  late QuantumPhysicsEngine quantumEngine;
  bool isQuantumMode = false;
  bool isGravityPaintMode = false;
  bool isPortalMode = false;
  
  // Game objects
  final List<QuantumGameObject> gameObjects = [];
  PortalOrb? firstPortal;
  
  QuantumGravityGame() : super(gravity: Vector2(0, 9.81));
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize quantum physics
    quantumEngine = QuantumPhysicsEngine(world);
    
    // Create starfield background
    add(UltraVisualEffects.createParticleStorm(
      position: size / 2,
      color: Colors.white.withValues(alpha: 0.3),
      particleCount: 1000,
      radius: size.length,
    ));
    
    // Setup level
    _createBoundaries();
    _createInitialObjects();
    
    // Add lighting effects
    add(UltraVisualEffects.createRayTracedLight(
      position: size / 2,
      radius: 200,
      color: Colors.cyan,
      rayCount: 180,
    ));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Use quantum physics engine
    quantumEngine.quantumStep(dt);
    
    // Update quantum objects
    for (final obj in gameObjects) {
      obj.applyQuantumEffects(dt);
    }
  }
  
  void _createBoundaries() {
    // Create walls
    final walls = [
      // Bottom
      Vector2(size.x / 2, size.y - 10),
      // Left
      Vector2(10, size.y / 2),
      // Right
      Vector2(size.x - 10, size.y / 2),
      // Top
      Vector2(size.x / 2, 10),
    ];
    
    final sizes = [
      Vector2(size.x, 20), // Bottom
      Vector2(20, size.y), // Left
      Vector2(20, size.y), // Right
      Vector2(size.x, 20), // Top
    ];
    
    for (int i = 0; i < walls.length; i++) {
      final wall = _createWall(walls[i], sizes[i]);
      add(wall);
    }
  }
  
  BodyComponent _createWall(Vector2 position, Vector2 size) {
    final wall = BodyComponent(
      bodyDef: BodyDef()
        ..type = BodyType.static
        ..position = position,
      fixtureDefs: [
        FixtureDef(PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2))
          ..friction = 0.3,
      ],
    );
    return wall;
  }
  
  void _createInitialObjects() {
    // Create diverse quantum objects
    final ball = QuantumBall(
      position: Vector2(size.x / 2 - 50, size.y / 2),
      color: Colors.green,
    );
    add(ball);
    gameObjects.add(ball);
    
    final cube = MassThiefCube(
      position: Vector2(size.x / 2 + 50, size.y / 2),
    );
    add(cube);
    gameObjects.add(cube);
    
    final balloon = AntigravBalloon(
      position: Vector2(size.x / 2, size.y / 2 + 100),
    );
    add(balloon);
    gameObjects.add(balloon);
    
    final energy = EnergySphere(
      position: Vector2(size.x / 2 - 100, size.y / 2 - 50),
    );
    add(energy);
    gameObjects.add(energy);
    
    final magnet1 = MagneticBall(
      position: Vector2(size.x / 2 + 100, size.y / 2 - 50),
      magnetStrength: 100,
    );
    add(magnet1);
    gameObjects.add(magnet1);
    
    final magnet2 = MagneticBall(
      position: Vector2(size.x / 2 + 100, size.y / 2 + 50),
      magnetStrength: -100, // Opposite polarity
    );
    add(magnet2);
    gameObjects.add(magnet2);
  }
  
  void rewindTime(double seconds) {
    quantumEngine.rewindTime(seconds);
    
    // Visual effect
    add(UltraVisualEffects.createDistortionField(
      center: size / 2,
      radius: size.length,
      strength: 2.0,
    ));
  }
  
  void toggleQuantumMode() {
    isQuantumMode = !isQuantumMode;
    
    if (isQuantumMode) {
      // Create superposition for random objects
      for (final obj in gameObjects) {
        if (obj.body.bodyType == BodyType.dynamic) {
          quantumEngine.createSuperposition(obj.body, 3);
          obj.isInSuperposition = true;
        }
      }
    } else {
      // Collapse all quantum states
      for (final obj in gameObjects) {
        quantumEngine.observeQuantumBody(obj.body);
        obj.isInSuperposition = false;
      }
    }
  }
  
  void paintGravityMode() {
    isGravityPaintMode = !isGravityPaintMode;
    // In paint mode, user can drag to create custom gravity fields
  }
  
  void activateEnergyBurst() {
    // Find all energy spheres and discharge them
    for (final obj in gameObjects) {
      if (obj is EnergySphere) {
        obj.discharge();
        
        // Visual explosion
        add(UltraVisualEffects.createExplosion(
          position: obj.body.position,
          color: Colors.yellow,
          intensity: 2.0,
        ));
      }
    }
  }
  
  void createPortalMode() {
    isPortalMode = !isPortalMode;
    // In portal mode, user can place two portals
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (isGravityPaintMode) {
      // Create gravity field at tap location
      quantumEngine.paintGravityField(
        event.localPosition,
        50,
        Vector2(0, -20), // Anti-gravity field
      );
      
      // Visual effect
      add(UltraVisualEffects.createQuantumTrail(
        position: event.localPosition,
        color: Colors.green,
      ));
    } else if (isPortalMode) {
      if (firstPortal == null) {
        // Create first portal
        firstPortal = PortalOrb(position: event.localPosition);
        add(firstPortal!);
        gameObjects.add(firstPortal!);
      } else {
        // Create second portal and link them
        final secondPortal = PortalOrb(position: event.localPosition);
        add(secondPortal);
        gameObjects.add(secondPortal);
        
        firstPortal!.linkTo(secondPortal);
        firstPortal = null;
        isPortalMode = false;
      }
    }
  }
}
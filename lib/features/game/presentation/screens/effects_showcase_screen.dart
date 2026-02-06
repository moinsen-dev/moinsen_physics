import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../../../core/physics/quantum_physics_engine.dart';
import '../../../../core/effects/ultra_visual_effects.dart';
import '../../../../core/effects/black_hole_effect.dart';
import '../../../../core/effects/quantum_field_effect.dart';
import '../../domain/entities/quantum_game_object.dart';

/// Mind-blowing effects showcase screen
class EffectsShowcaseScreen extends StatefulWidget {
  const EffectsShowcaseScreen({super.key});

  @override
  State<EffectsShowcaseScreen> createState() => _EffectsShowcaseScreenState();
}

class _EffectsShowcaseScreenState extends State<EffectsShowcaseScreen> {
  late final EffectsShowcaseGame game;
  
  @override
  void initState() {
    super.initState();
    game = EffectsShowcaseGame();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game view
          GameWidget(game: game),
          
          // Effects control panel
          Positioned(
            top: 50,
            right: 20,
            child: _buildEffectsPanel(),
          ),
          
          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEffectsPanel() {
    return Container(
      width: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EFFECTS LAB',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          _buildEffectButton(
            'BLACK HOLE',
            Colors.purple,
            Icons.circle,
            () => game.spawnBlackHole(),
          ),
          SizedBox(height: 8),
          _buildEffectButton(
            'QUANTUM FIELD',
            Colors.cyan,
            Icons.blur_on,
            () => game.spawnQuantumField(),
          ),
          SizedBox(height: 8),
          _buildEffectButton(
            'PARTICLE STORM',
            Colors.orange,
            Icons.whatshot,
            () => game.createParticleStorm(),
          ),
          SizedBox(height: 8),
          _buildEffectButton(
            'ANTIMATTER',
            Colors.red,
            Icons.flash_on,
            () => game.spawnAntimatter(),
          ),
          SizedBox(height: 8),
          _buildEffectButton(
            'TIME CRYSTAL',
            Colors.blue,
            Icons.access_time,
            () => game.spawnTimeCrystal(),
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white24),
          SizedBox(height: 8),
          _buildEffectButton(
            'CLEAR ALL',
            Colors.grey,
            Icons.clear,
            () => game.clearAllEffects(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEffectButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Game engine showcasing all visual effects
class EffectsShowcaseGame extends Forge2DGame with TapDetector, DragCallbacks {
  late QuantumPhysicsEngine quantumEngine;
  final List<QuantumGameObject> physicsObjects = [];
  final List<Component> effectComponents = [];
  
  // Drag state
  Vector2? dragStart;
  Vector2? dragEnd;
  
  EffectsShowcaseGame() : super(gravity: Vector2(0, 9.81));
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize quantum physics
    quantumEngine = QuantumPhysicsEngine(world);
    
    // Create epic background
    add(UltraVisualEffects.createParticleStorm(
      position: size / 2,
      color: Colors.deepPurple.withValues(alpha: 0.1),
      particleCount: 500,
      radius: size.length,
    ));
    
    // Create boundaries
    _createBoundaries();
    
    // Add initial physics objects
    _spawnPhysicsObjects();
    
    // Add ambient effects
    _addAmbientEffects();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update quantum physics
    quantumEngine.quantumStep(dt);
    
    // Update quantum fields
    for (final component in effectComponents) {
      if (component is QuantumFieldComponent) {
        component.applyQuantumEffects(world);
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw drag line
    if (dragStart != null && dragEnd != null) {
      final paint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.5)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        dragStart!.toOffset(),
        dragEnd!.toOffset(),
        paint,
      );
      
      // Draw arrow
      final direction = (dragEnd! - dragStart!).normalized();
      final arrowLength = 20.0;
      final arrowAngle = 0.5;
      
      final arrow1 = dragEnd! - direction * arrowLength;
      final arrow2 = arrow1 + Vector2(
        -direction.y * sin(arrowAngle) - direction.x * cos(arrowAngle),
        direction.x * sin(arrowAngle) - direction.y * cos(arrowAngle),
      ) * arrowLength * 0.5;
      final arrow3 = arrow1 + Vector2(
        direction.y * sin(arrowAngle) - direction.x * cos(arrowAngle),
        -direction.x * sin(arrowAngle) - direction.y * cos(arrowAngle),
      ) * arrowLength * 0.5;
      
      canvas.drawLine(dragEnd!.toOffset(), arrow2.toOffset(), paint);
      canvas.drawLine(dragEnd!.toOffset(), arrow3.toOffset(), paint);
    }
  }
  
  void _createBoundaries() {
    final walls = [
      _createWall(Vector2(size.x / 2, 10), Vector2(size.x, 20)),
      _createWall(Vector2(size.x / 2, size.y - 10), Vector2(size.x, 20)),
      _createWall(Vector2(10, size.y / 2), Vector2(20, size.y)),
      _createWall(Vector2(size.x - 10, size.y / 2), Vector2(20, size.y)),
    ];
    
    for (final wall in walls) {
      add(wall);
    }
  }
  
  BodyComponent _createWall(Vector2 position, Vector2 size) {
    return BodyComponent(
      bodyDef: BodyDef()
        ..type = BodyType.static
        ..position = position,
      fixtureDefs: [
        FixtureDef(PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2))
          ..friction = 0.3
          ..restitution = 0.5,
      ],
    );
  }
  
  void _spawnPhysicsObjects() {
    // Spawn various objects
    for (int i = 0; i < 10; i++) {
      final types = [
        () => QuantumBall(
          position: Vector2(
            100 + Random().nextDouble() * (size.x - 200),
            100 + Random().nextDouble() * (size.y - 200),
          ),
          color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        ),
        () => EnergySphere(
          position: Vector2(
            100 + Random().nextDouble() * (size.x - 200),
            100 + Random().nextDouble() * (size.y - 200),
          ),
        ),
        () => MagneticBall(
          position: Vector2(
            100 + Random().nextDouble() * (size.x - 200),
            100 + Random().nextDouble() * (size.y - 200),
          ),
          magnetStrength: Random().nextDouble() * 200 - 100,
        ),
      ];
      
      final object = types[Random().nextInt(types.length)]();
      add(object);
      physicsObjects.add(object);
    }
  }
  
  void _addAmbientEffects() {
    // Add floating particles
    add(UltraVisualEffects.createQuantumTrail(
      position: size / 2,
      color: Colors.cyan.withValues(alpha: 0.5),
    ));
  }
  
  void spawnBlackHole() {
    final blackHole = BlackHoleComponent(
      position: size / 2 + Vector2(
        (Random().nextDouble() - 0.5) * 200,
        (Random().nextDouble() - 0.5) * 200,
      ),
      world: world,
      radius: 150,
      eventHorizonRadius: 30,
      maxForce: 3000,
    );
    
    add(blackHole);
    effectComponents.add(blackHole);
    
    // Add dramatic spawn effect
    add(UltraVisualEffects.createExplosion(
      position: blackHole.position,
      color: Colors.purple,
      intensity: 3.0,
    ));
  }
  
  void spawnQuantumField() {
    final quantumField = QuantumFieldComponent(
      position: size / 2 + Vector2(
        (Random().nextDouble() - 0.5) * 200,
        (Random().nextDouble() - 0.5) * 200,
      ),
      fieldRadius: 150,
      waveCount: 5,
      primaryColor: Colors.cyan,
      secondaryColor: Colors.purple,
    );
    
    add(quantumField);
    effectComponents.add(quantumField);
    
    // Add spawn effect
    add(UltraVisualEffects.createDistortionField(
      center: quantumField.position,
      radius: 200,
      strength: 1.0,
    ));
  }
  
  void createParticleStorm() {
    add(UltraVisualEffects.createParticleStorm(
      position: size / 2,
      color: Colors.orange,
      particleCount: 5000,
      radius: 300,
    ));
  }
  
  void spawnAntimatter() {
    // Create antimatter object
    final antimatter = QuantumBall(
      position: size / 2 + Vector2(
        (Random().nextDouble() - 0.5) * 200,
        (Random().nextDouble() - 0.5) * 200,
      ),
      color: Colors.red,
    );
    antimatter.hasAntimatterProperties = true;
    
    add(antimatter);
    physicsObjects.add(antimatter);
    
    // Add annihilation readiness effect
    add(UltraVisualEffects.createAnnihilation(
      position: antimatter.body.position,
    ));
  }
  
  void spawnTimeCrystal() {
    final timeCrystal = TimeCrystal(
      position: size / 2 + Vector2(
        (Random().nextDouble() - 0.5) * 200,
        (Random().nextDouble() - 0.5) * 200,
      ),
    );
    
    add(timeCrystal);
    physicsObjects.add(timeCrystal);
    
    // Add time distortion effect
    add(UltraVisualEffects.createDistortionField(
      center: timeCrystal.body.position,
      radius: timeCrystal.timeFieldRadius,
      strength: 2.0,
    ));
  }
  
  void clearAllEffects() {
    // Remove all effect components
    for (final effect in effectComponents) {
      remove(effect);
    }
    effectComponents.clear();
    
    // Remove all physics objects
    for (final obj in physicsObjects) {
      remove(obj);
    }
    physicsObjects.clear();
    
    // Respawn basic objects
    _spawnPhysicsObjects();
  }
  
  @override
  void onTapDown(TapDownInfo info) {
    // Create explosion at tap location
    add(UltraVisualEffects.createExplosion(
      position: info.eventPosition.global,
      color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
      intensity: 1.5,
    ));
  }
  
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragStart = event.localPosition;
    dragEnd = dragStart;
  }
  
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    dragEnd = event.localEndPosition;
  }
  
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (dragStart != null && dragEnd != null) {
      // Launch object in drag direction
      final direction = (dragEnd! - dragStart!).normalized();
      final force = (dragEnd! - dragStart!).length * 50;
      
      // Find nearest object
      QuantumGameObject? nearest;
      double minDistance = double.infinity;
      
      for (final obj in physicsObjects) {
        final distance = (obj.body.position - dragStart!).length;
        if (distance < minDistance) {
          minDistance = distance;
          nearest = obj;
        }
      }
      
      if (nearest != null && minDistance < 50) {
        nearest.body.applyLinearImpulse(direction * force * nearest.body.mass);
        
        // Add trail effect
        add(UltraVisualEffects.createQuantumTrail(
          position: nearest.body.position,
          color: Colors.yellow,
        ));
      }
    }
    
    dragStart = null;
    dragEnd = null;
  }
}
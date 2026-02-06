import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Revolutionary quantum physics engine for Gravity Lab 2.0
/// Supports time manipulation, quantum superposition, and reality-bending mechanics
class QuantumPhysicsEngine {
  final Forge2DWorld world;
  final Random _random = Random();
  
  // Time manipulation
  double timeScale = 1.0;
  final List<WorldSnapshot> _timelineHistory = [];
  static const int maxHistoryFrames = 300; // 5 seconds at 60fps
  
  // Quantum states
  final Map<Body, List<QuantumState>> _quantumStates = {};
  
  // Gravity fields
  final List<CustomGravityField> _gravityFields = [];
  Vector2 baseGravity = Vector2(0, 9.81);
  
  // Reality distortion
  final Map<Vector2, SpaceDistortion> _spaceDistortions = {};
  
  QuantumPhysicsEngine(this.world);
  
  /// Update physics with quantum mechanics
  void quantumStep(double dt) {
    // Apply time scaling
    final scaledDt = dt * timeScale;
    
    // Record history for time rewind
    if (timeScale >= 0) {
      _recordSnapshot();
    }
    
    // Update quantum states
    _updateQuantumStates(scaledDt);
    
    // Apply custom gravity fields
    _applyGravityFields(scaledDt);
    
    // Process space distortions
    _processSpaceDistortions(scaledDt);
    
    // Standard physics step is handled by Forge2DGame
    // The world physics will be stepped automatically by the game engine
    // We've already applied our custom quantum effects above
  }
  
  /// Rewind time by specified seconds
  void rewindTime(double seconds) {
    final framesToRewind = (seconds * 60).round();
    final targetFrame = (_timelineHistory.length - framesToRewind).clamp(0, _timelineHistory.length - 1);
    
    if (targetFrame < _timelineHistory.length) {
      _restoreSnapshot(_timelineHistory[targetFrame]);
      // Clear future history
      _timelineHistory.removeRange(targetFrame + 1, _timelineHistory.length);
    }
  }
  
  /// Fast forward time
  void fastForward(double speed) {
    timeScale = speed.clamp(0.1, 5.0);
  }
  
  /// Create quantum superposition for a body
  void createSuperposition(Body body, int states) {
    final positions = <QuantumState>[];
    final basePos = body.position.clone();
    
    for (int i = 0; i < states; i++) {
      final angle = (i / states) * 2 * pi;
      final offset = Vector2(cos(angle), sin(angle)) * 2.0;
      positions.add(QuantumState(
        position: basePos + offset,
        probability: 1.0 / states,
        phase: angle,
      ));
    }
    
    _quantumStates[body] = positions;
  }
  
  /// Collapse quantum state when observed
  void observeQuantumBody(Body body) {
    final states = _quantumStates[body];
    if (states == null || states.isEmpty) return;
    
    // Collapse to most probable state
    double totalProb = 0;
    final random = _random.nextDouble();
    
    for (final state in states) {
      totalProb += state.probability;
      if (random <= totalProb) {
        body.setTransform(state.position, body.angle);
        _quantumStates.remove(body);
        break;
      }
    }
  }
  
  /// Paint custom gravity field
  void paintGravityField(Vector2 center, double radius, Vector2 gravity) {
    _gravityFields.add(CustomGravityField(
      center: center,
      radius: radius,
      gravity: gravity,
      strength: 1.0,
    ));
  }
  
  /// Create dimensional rift
  void createDimensionalRift(Vector2 position, Vector2 targetPosition) {
    _spaceDistortions[position] = SpaceDistortion(
      type: DistortionType.portal,
      strength: 1.0,
      targetPosition: targetPosition,
      radius: 3.0,
    );
  }
  
  /// Transfer mass between objects
  void transferMass(Body from, Body to, double amount) {
    final fromMass = from.mass;
    final toMass = to.mass;
    
    if (fromMass > amount) {
      // Update masses
      // Create new fixtures with updated density to change mass
      final fromDensity = from.fixtures.first.density;
      final toDensity = to.fixtures.first.density;
      
      final newFromDensity = fromDensity * ((fromMass - amount) / fromMass);
      final newToDensity = toDensity * ((toMass + amount) / toMass);
      
      // Update densities
      for (final fixture in from.fixtures) {
        fixture.density = newFromDensity;
      }
      for (final fixture in to.fixtures) {
        fixture.density = newToDensity;
      }
      
      from.resetMassData();
      to.resetMassData();
    }
  }
  
  /// Stretch or compress space
  void distortSpace(Vector2 center, double radius, double compressionFactor) {
    _spaceDistortions[center] = SpaceDistortion(
      type: DistortionType.compression,
      strength: compressionFactor,
      radius: radius,
    );
  }
  
  void _recordSnapshot() {
    if (_timelineHistory.length >= maxHistoryFrames) {
      _timelineHistory.removeAt(0);
    }
    
    final bodies = <BodySnapshot>[];
    for (final body in world.physicsWorld.bodies) {
      bodies.add(BodySnapshot(
        position: body.position.clone(),
        angle: body.angle,
        linearVelocity: body.linearVelocity.clone(),
        angularVelocity: body.angularVelocity,
      ));
    }
    
    _timelineHistory.add(WorldSnapshot(
      timestamp: DateTime.now(),
      bodies: bodies,
      gravity: baseGravity.clone(),
    ));
  }
  
  void _restoreSnapshot(WorldSnapshot snapshot) {
    int index = 0;
    for (final body in world.physicsWorld.bodies) {
      if (index < snapshot.bodies.length) {
        final bodySnapshot = snapshot.bodies[index];
        body.setTransform(bodySnapshot.position, bodySnapshot.angle);
        body.linearVelocity = bodySnapshot.linearVelocity;
        body.angularVelocity = bodySnapshot.angularVelocity;
        index++;
      }
    }
    baseGravity = snapshot.gravity;
  }
  
  void _updateQuantumStates(double dt) {
    _quantumStates.forEach((body, states) {
      for (final state in states) {
        // Quantum phase evolution
        state.phase += dt * 2 * pi;
        
        // Probability wave function
        state.probability = (sin(state.phase) + 1) / 2 / states.length;
      }
    });
  }
  
  void _applyGravityFields(double dt) {
    for (final body in world.physicsWorld.bodies) {
      Vector2 totalGravity = baseGravity.clone();
      
      for (final field in _gravityFields) {
        final distance = (body.position - field.center).length;
        if (distance < field.radius) {
          final factor = 1 - (distance / field.radius);
          totalGravity += field.gravity * factor * field.strength.toDouble();
        }
      }
      
      body.applyForce(totalGravity * body.mass);
    }
  }
  
  void _processSpaceDistortions(double dt) {
    _spaceDistortions.forEach((position, distortion) {
      for (final body in world.physicsWorld.bodies) {
        final distance = (body.position - position).length;
        
        if (distance < distortion.radius) {
          switch (distortion.type) {
            case DistortionType.portal:
              if (distance < 0.5 && distortion.targetPosition != null) {
                body.setTransform(distortion.targetPosition!, body.angle);
              }
              break;
              
            case DistortionType.compression:
              final direction = (body.position - position).normalized();
              final force = direction * distortion.strength * (1 - distance / distortion.radius);
              body.applyForce(force * body.mass);
              break;
          }
        }
      }
    });
  }
}

class QuantumState {
  Vector2 position;
  double probability;
  double phase;
  
  QuantumState({
    required this.position,
    required this.probability,
    required this.phase,
  });
}

class CustomGravityField {
  final Vector2 center;
  final double radius;
  final Vector2 gravity;
  final double strength;
  
  CustomGravityField({
    required this.center,
    required this.radius,
    required this.gravity,
    required this.strength,
  });
}

class SpaceDistortion {
  final DistortionType type;
  final double strength;
  final double radius;
  final Vector2? targetPosition;
  
  SpaceDistortion({
    required this.type,
    required this.strength,
    required this.radius,
    this.targetPosition,
  });
}

enum DistortionType {
  portal,
  compression,
}

class WorldSnapshot {
  final DateTime timestamp;
  final List<BodySnapshot> bodies;
  final Vector2 gravity;
  
  WorldSnapshot({
    required this.timestamp,
    required this.bodies,
    required this.gravity,
  });
}

class BodySnapshot {
  final Vector2 position;
  final double angle;
  final Vector2 linearVelocity;
  final double angularVelocity;
  
  BodySnapshot({
    required this.position,
    required this.angle,
    required this.linearVelocity,
    required this.angularVelocity,
  });
}
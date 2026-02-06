import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Quantum-enhanced physics objects for Gravity Lab 2.0
abstract class QuantumGameObject extends BodyComponent {
  final String objectType;
  final Color baseColor;
  
  // Quantum properties
  bool isInSuperposition = false;
  bool hasAntimatterProperties = false;
  double quantumPhase = 0.0;
  
  // Enhanced physics properties
  double elasticity = 0.5;
  double magnetism = 0.0;
  double temporalStability = 1.0;
  
  QuantumGameObject({
    required this.objectType,
    required this.baseColor,
  });
  
  /// Apply quantum effects to the object
  void applyQuantumEffects(double dt) {
    if (isInSuperposition) {
      quantumPhase += dt * 2 * 3.14159;
      // Visual oscillation effect
      paint.color = baseColor.withValues(
        alpha: 0.5 + 0.5 * sin(quantumPhase),
      );
    }
  }
  
  /// Handle antimatter collision
  void onAntimatterCollision(QuantumGameObject other) {
    if (hasAntimatterProperties && !other.hasAntimatterProperties) {
      // Trigger annihilation
      world.remove(this);
      world.remove(other);
    }
  }
}

/// Standard physics ball with quantum capabilities
class QuantumBall extends QuantumGameObject {
  final double radius;
  
  QuantumBall({
    required Vector2 position,
    this.radius = 1.0,
    Color color = Colors.green,
  }) : super(objectType: 'ball', baseColor: color);
  
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.3
      ..restitution = elasticity;
      
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;
      
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

/// Heavy cube that can steal mass
class MassThiefCube extends QuantumGameObject {
  final double size;
  double stolenMass = 0;
  
  MassThiefCube({
    required Vector2 position,
    this.size = 2.0,
  }) : super(objectType: 'cube', baseColor: Colors.blue);
  
  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(size / 2, size / 2);
    final fixtureDef = FixtureDef(shape)
      ..density = 5.0
      ..friction = 0.5
      ..restitution = 0.2;
      
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;
      
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
  
  void stealMass(Body target, double amount) {
    stolenMass += amount;
    // Update own density
    for (final fixture in body.fixtures) {
      fixture.density *= 1 + (amount / body.mass);
    }
    body.resetMassData();
  }
}

/// Balloon that defies gravity
class AntigravBalloon extends QuantumGameObject {
  final double radius;
  
  AntigravBalloon({
    required Vector2 position,
    this.radius = 1.5,
  }) : super(objectType: 'balloon', baseColor: Colors.pink);
  
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..density = 0.1
      ..friction = 0.1
      ..restitution = 0.8;
      
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position
      ..gravityOverride = Vector2(0, -9.81); // Negative gravity!
      
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

/// Ghost object that phases through matter
class GhostOrb extends QuantumGameObject {
  final double radius;
  bool isPhasing = false;
  
  GhostOrb({
    required Vector2 position,
    this.radius = 1.2,
  }) : super(objectType: 'ghost', baseColor: Colors.white70);
  
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..density = 0.5
      ..friction = 0.0
      ..restitution = 0.5
      ..isSensor = isPhasing; // Can pass through objects when phasing
      
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;
      
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
  
  void togglePhasing() {
    isPhasing = !isPhasing;
    // Recreate fixture with new sensor setting
    body.fixtures.first.setSensor(isPhasing);
  }
}

/// Energy sphere that creates chain reactions
class EnergySphere extends QuantumGameObject {
  final double radius;
  double chargeLevel = 1.0;
  
  EnergySphere({
    required Vector2 position,
    this.radius = 1.0,
  }) : super(objectType: 'energy', baseColor: Colors.yellow);
  
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..density = 0.8
      ..friction = 0.2
      ..restitution = 1.2; // Super bouncy!
      
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;
      
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
  
  void discharge() {
    if (chargeLevel > 0.5) {
      // Apply explosive force to nearby objects
      final explosionRadius = 5.0;
      final explosionForce = 1000.0 * chargeLevel;
      
      for (final other in world.physicsWorld.bodies) {
        final distance = (other.position - body.position).length;
        if (distance < explosionRadius && distance > 0) {
          final direction = (other.position - body.position).normalized();
          final force = direction * explosionForce * (1 - distance / explosionRadius);
          other.applyLinearImpulse(force * other.mass);
        }
      }
      
      chargeLevel = 0.1;
    }
  }
}

/// Magnetic object that attracts/repels
class MagneticBall extends QuantumGameObject {
  final double radius;
  final double magnetStrength;
  
  MagneticBall({
    required Vector2 position,
    this.radius = 1.3,
    this.magnetStrength = 100.0,
  }) : super(objectType: 'magnet', baseColor: Colors.red) {
    magnetism = magnetStrength;
  }
  
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..density = 3.0
      ..friction = 0.4
      ..restitution = 0.3;
      
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;
      
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    applyMagneticForces();
  }
  
  void applyMagneticForces() {
    for (final other in world.physicsWorld.bodies) {
      if (other != body && other.userData is MagneticBall) {
        final distance = (other.position - body.position).length;
        if (distance < 10 && distance > 0.5) {
          final direction = (other.position - body.position).normalized();
          final otherMagnet = other.userData as MagneticBall;
          
          // Same polarity repels, opposite attracts
          final force = direction * magnetStrength * otherMagnet.magnetStrength / (distance * distance);
          final attractionFactor = magnetism * otherMagnet.magnetism < 0 ? 1 : -1;
          
          body.applyForce(force * attractionFactor.toDouble());
          other.applyForce(-force * attractionFactor.toDouble());
        }
      }
    }
  }
}

/// Portal object that teleports other objects
class PortalOrb extends QuantumGameObject {
  final double radius;
  PortalOrb? linkedPortal;
  
  PortalOrb({
    required Vector2 position,
    this.radius = 2.0,
  }) : super(objectType: 'portal', baseColor: Colors.purple);
  
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..density = 1000.0 // Immovable
      ..friction = 0.0
      ..restitution = 0.0
      ..isSensor = true;
      
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = position;
      
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
  
  void linkTo(PortalOrb other) {
    linkedPortal = other;
    other.linkedPortal = this;
  }
  
  void teleport(Body object) {
    if (linkedPortal != null) {
      final velocity = object.linearVelocity.clone();
      object.setTransform(linkedPortal!.body.position, object.angle);
      object.linearVelocity = velocity;
    }
  }
}

/// Time crystal that can freeze/slow time locally
class TimeCrystal extends QuantumGameObject {
  final double radius;
  final double timeFieldRadius;
  double timeScale = 0.1;
  
  TimeCrystal({
    required Vector2 position,
    this.radius = 1.5,
    this.timeFieldRadius = 5.0,
  }) : super(objectType: 'timecrystal', baseColor: Colors.cyan) {
    temporalStability = 0.0; // Immune to time effects
  }
  
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..density = 10.0
      ..friction = 0.8
      ..restitution = 0.1;
      
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;
      
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
  
  List<Body> getAffectedBodies() {
    final affected = <Body>[];
    for (final other in world.physicsWorld.bodies) {
      if (other != body) {
        final distance = (other.position - body.position).length;
        if (distance < timeFieldRadius) {
          affected.add(other);
        }
      }
    }
    return affected;
  }
}
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../controls/simulation_controls.dart';
import 'ball_body.dart';

class NewtonCradleGame extends Forge2DGame {
  SimulationControls controls;
  final List<BallBody> balls = [];
  Body? supportBar;
  Function(double velocity)? onCollision;
  final double gameZoom = 40.0;

  NewtonCradleGame({
    required this.controls,
    this.onCollision,
  }) : super(
          gravity: Vector2(0, 9.8),
          world: Forge2DWorld(gravity: Vector2(0, 9.8)),
        ) {
    debugMode = true;
  }

  void updateControls(SimulationControls newControls) {
    controls = newControls;
    _createCradle();
  }

  @override
  Future<void> onLoad() async {
    try {
      await super.onLoad();
      debugPrint('Game onLoad started');

      camera.viewport = FixedResolutionViewport(resolution: Vector2(400, 600));
      camera.viewfinder.zoom = gameZoom;
      camera.viewfinder.anchor = Anchor.center;
      camera.moveTo(Vector2(0, 0));

      debugPrint('Camera setup complete');
      await _createCradle();
      debugPrint('Cradle creation complete');
    } catch (e, stackTrace) {
      debugPrint('Error in onLoad: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _createCradle() async {
    try {
      // Clean up existing bodies
      for (final ball in balls) {
        world.destroyBody(ball.body);
      }
      balls.clear();

      if (supportBar != null) {
        world.destroyBody(supportBar!);
        supportBar = null;
      }

      _createSupportBar();
      await _createBalls();
    } catch (e, stackTrace) {
      debugPrint('Error creating cradle: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void _createSupportBar() {
    final worldHeight = 15.0;
    final worldWidth =
        worldHeight * (camera.viewport.size.x / camera.viewport.size.y);
    final Vector2 center = Vector2(0, -worldHeight * 0.2);
    final barWidth = worldWidth * 0.6;

    final barDef = BodyDef()
      ..type = BodyType.static
      ..position = center
      ..userData = this;

    supportBar = world.createBody(barDef);

    final shape = PolygonShape()
      ..setAsBox(barWidth / 2, 0.2, Vector2.zero(), 0.0);

    supportBar!.createFixture(
      FixtureDef(shape)
        ..density = 1.0
        ..friction = 0.3
        ..restitution = 0.5,
    );
  }

  Future<void> _createBalls() async {
    if (supportBar == null) return;

    final worldHeight = 15.0;
    final worldWidth =
        worldHeight * (camera.viewport.size.x / camera.viewport.size.y);
    final Vector2 center = Vector2(0, -worldHeight * 0.2);
    final barWidth = worldWidth * 0.6;

    final ballRadius =
        (barWidth / (controls.numberOfBalls * 3)).clamp(0.3, 1.0);
    final startX = -barWidth / 2 + ballRadius;
    final ballSpacing = ballRadius * 2.2;

    for (int i = 0; i < controls.numberOfBalls; i++) {
      final ball = BallBody(
        initialPosition: Vector2(
          startX + (i * ballSpacing),
          center.y + (controls.ropeLength / 100),
        ),
        radius: ballRadius,
        color: controls.ballColor,
        mass: controls.ballWeightGrams / 100,
        game: this,
      );

      await add(ball);
      balls.add(ball);

      _createRopeJoint(ball, startX + (i * ballSpacing) - center.x, ballRadius);
    }

    if (balls.isNotEmpty) {
      _applyInitialImpulse();
    }
  }

  void _createRopeJoint(BallBody ball, double anchorX, double ballRadius) {
    final ropeJointDef = RopeJointDef()
      ..bodyA = supportBar!
      ..bodyB = ball.body
      ..localAnchorA.setValues(anchorX, 0)
      ..localAnchorB.setValues(0, -ballRadius)
      ..maxLength = controls.ropeLength / 100;

    world.createJoint(RopeJoint(ropeJointDef));
  }

  void _applyInitialImpulse() {
    final firstBall = balls.first;
    firstBall.body.applyLinearImpulse(
      Vector2(3.0, 0),
      point: firstBall.body.position,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    world.update(dt.clamp(0, 1 / 60));
  }

  void resetBalls() {
    _createCradle();
  }
}

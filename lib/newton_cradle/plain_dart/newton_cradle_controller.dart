import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

import '../_index.dart';

class NewtonCradleController {
  final TickerProvider vsync;
  final VoidCallback onUpdate;
  late AnimationController animationController;
  List<Ball> balls = [];
  late double originY;
  Soundpool? soundpool;
  int? soundId;
  SimulationControls controls;

  NewtonCradleController({
    required this.vsync,
    required this.onUpdate,
    required this.controls,
  }) {
    _initializeController();
    _initSound();
  }

  void _initializeController() {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        update();
        onUpdate();
      });
    animationController.repeat();
  }

  Future<void> _initSound() async {
    try {
      soundpool = Soundpool.fromOptions(
        options: SoundpoolOptions(
          streamType: StreamType.notification,
          maxStreams: 4,
        ),
      );

      soundId = await rootBundle
          .load('assets/sounds/click.wav')
          .then((ByteData data) => soundpool!.load(data));
    } catch (e) {
      debugPrint('Error initializing sound: $e');
    }
  }

  void updateBalls(BuildContext context) {
    final size = MediaQuery.of(context).size;
    originY = size.height * 0.3;

    final centerX = size.width / 2;
    final totalWidth = controls.ballRadius * 2.0 * (controls.numberOfBalls - 1);
    final startX = centerX - totalWidth / 2;

    balls.clear();

    // Create new balls with exact spacing
    for (int i = 0; i < controls.numberOfBalls; i++) {
      final xPos = startX + i * controls.ballRadius * 2.0;
      final ball = Ball(
        index: i,
        origin: Offset(xPos, originY),
        position: Offset(
          xPos,
          originY + controls.ropeLength,
        ),
        length: controls.ropeLength,
      );
      balls.add(ball);
    }

    // Initial condition: pull first ball back
    if (balls.isNotEmpty) {
      balls.first.setAngle(-pi / 4); // 45 degrees
    }
  }

  void update() {
    const double dt =
        0.016 * 2.0; // Doubled time step for even faster simulation

    // Update ball positions
    for (var ball in balls) {
      ball.update(dt);
    }

    // Handle collisions
    _handleCollisions();
  }

  void _handleCollisions() {
    for (int i = 0; i < balls.length - 1; i++) {
      Ball ball1 = balls[i];
      Ball ball2 = balls[i + 1];

      if (ball1.isColliding(ball2, controls.ballRadius)) {
        if (!ball1.isDragging && !ball2.isDragging) {
          // Perfect elastic collision for Newton's Cradle
          double v1 = ball1.getLinearVelocity();
          double v2 = ball2.getLinearVelocity();

          // Only transfer momentum if balls are moving towards each other
          if (v1 > v2) {
            // Exchange velocities for perfect elastic collision
            ball1.applyImpulse(v2);
            ball2.applyImpulse(v1);

            // Play sound if collision is significant
            double relativeVelocity = (v1 - v2).abs();
            if (relativeVelocity > 0.1) {
              _playCollisionSound(relativeVelocity);
            }
          }
        }
      }
    }
  }

  void _playCollisionSound(double velocity) async {
    if (!controls.isSoundEnabled || soundId == null || soundId! <= 0) return;

    try {
      final double rate = 1.0 + (velocity * 0.2).clamp(-0.2, 0.2);
      final double volume = (velocity.abs() * 0.5).clamp(0.1, 1.0);

      soundpool?.setVolume(soundId: soundId!, volume: volume);
      await soundpool?.play(soundId!, rate: rate);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void dispose() {
    animationController.dispose();
    soundpool?.dispose();
  }
}

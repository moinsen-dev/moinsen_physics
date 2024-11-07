import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' show log;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';

import '../_index.dart';

class NewtonCradleController {
  final TickerProvider vsync;
  final VoidCallback onUpdate;
  AnimationController? animationController;
  List<Ball> balls = [];
  late double originY;
  FlutterSoundPlayer? _soundPlayer;
  int? soundId;
  SimulationControls controls;

  final double _gyroX = 0.0;
  final double _gyroY = 0.0;

  ByteData? _soundData;

  NewtonCradleController({
    required this.vsync,
    required this.onUpdate,
    required this.controls,
  }) {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

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
    animationController!.repeat();
  }

  Future<void> _initSound() async {
    try {
      _soundPlayer = FlutterSoundPlayer();
      _soundPlayer!.setLogLevel(Level.off);
      await _soundPlayer!.openPlayer();

      // Load sound data once during initialization
      _soundData = await rootBundle.load('assets/sounds/click.wav');
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

    // Remove initial pull back of first ball
    // The simulation will now start with balls at rest
    // if (balls.isNotEmpty) {
    //   balls.first.setAngle(-pi / 4); // 45 degrees
    // }
  }

  void update() {
    const double dt = 0.016 * 2.0;

    // Calculate gyroscope influence with adjusted sensitivity for portrait mode
    double gravityX = _gyroY * 3.0; // Side-to-side tilt

    // Use normal gravity when there's no significant gyro movement
    if (_gyroX.abs() < 0.1) {
      // Normal pendulum physics
      for (var ball in balls) {
        ball.update(dt);
      }
    } else {
      // Modified gravity for portrait orientation
      double gravityY = 9.81 - (_gyroX * 3.0); // Forward/backward tilt
      // Subtract to match tilt direction

      for (var ball in balls) {
        if (!ball.isDragging) {
          ball.updateWithGravity(dt, gravityX, gravityY);
        }
      }
    }

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
    if (!controls.isSoundEnabled ||
        _soundPlayer == null ||
        !_soundPlayer!.isOpen() ||
        _soundData == null) return;

    try {
      // Adjust pitch based on velocity (smaller range for more natural sound)
      final double rate = 1.0 + (velocity * 0.1).clamp(-0.1, 0.1);

      // Calculate volume based on collision force
      // Map velocity to a reasonable volume range (0.1 to 1.0)
      // Using log scale for more natural sound perception
      final double volume =
          (0.1 + 0.9 * (log(1 + velocity) / log(5))).clamp(0.1, 1.0);

      _soundPlayer!.setVolume(volume);
      _soundPlayer!.setSpeed(rate);

      await _soundPlayer!.startPlayer(
        fromDataBuffer: _soundData!.buffer.asUint8List(),
      );
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void dispose() {
    animationController?.dispose();
    _soundPlayer?.closePlayer();
  }
}

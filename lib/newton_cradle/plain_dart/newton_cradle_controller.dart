import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' show log;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      _soundData = await rootBundle.load('assets/sounds/click.wav');
    } catch (e) {
      debugPrint('Error initializing sound: $e');
    }
  }

  void update() {
    const double dt = 0.016 * 2.0;

    // Update positions
    for (var ball in balls) {
      ball.update(dt);
    }

    // Check for collisions
    for (int i = 0; i < balls.length - 1; i++) {
      Ball ball1 = balls[i];
      Ball ball2 = balls[i + 1];

      if (ball1.isColliding(ball2, controls.ballRadius)) {
        if (!ball1.isDragging && !ball2.isDragging) {
          double v1 = ball1.getLinearVelocity();
          double v2 = ball2.getLinearVelocity();

          // Only transfer momentum if balls are moving towards each other
          if (v1 > v2) {
            // Exchange velocities for perfect elastic collision
            ball1.applyImpulse(v2 - v1);
            ball2.applyImpulse(v1 - v2);

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

  void updateBalls(BuildContext context) {
    final size = MediaQuery.of(context).size;
    originY = size.height * 0.3;

    final centerX = size.width / 2;
    final totalWidth = controls.ballRadius * 2.0 * (controls.numberOfBalls - 1);
    final startX = centerX - totalWidth / 2;

    balls.clear();

    for (int i = 0; i < controls.numberOfBalls; i++) {
      final xPos = startX + i * controls.ballRadius * 2.0;
      final ballPosition = Offset(
        xPos,
        originY + controls.ropeLength,
      );

      final ball = controls.useRubberBands
          ? RubberBandBall(
              index: i,
              origin: Offset(xPos, originY),
              position: ballPosition,
              length: controls.ropeLength,
            )
          : PendulumBall(
              index: i,
              origin: Offset(xPos, originY),
              position: ballPosition,
              length: controls.ropeLength,
            );

      balls.add(ball);
    }
  }

  void handlePanStart(DragStartDetails details, Size size) {
    final touchPoint = details.localPosition;

    for (var ball in balls) {
      final distance = (touchPoint - ball.position).distance;
      if (distance <= controls.ballRadius) {
        ball.startDragging(touchPoint);
        break;
      }
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    for (var ball in balls) {
      if (ball.isDragging) {
        ball.updateDragPosition(details.localPosition);
        break;
      }
    }
  }

  void handlePanEnd(DragEndDetails details) {
    for (var ball in balls) {
      if (ball.isDragging) {
        ball.endDragging();
        break;
      }
    }
  }

  void _playCollisionSound(double velocity) async {
    if (!controls.isSoundEnabled ||
        _soundPlayer == null ||
        !_soundPlayer!.isOpen() ||
        _soundData == null) return;

    try {
      final double rate = 1.0 + (velocity * 0.1).clamp(-0.1, 0.1);
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

import 'dart:math';

import 'package:flutter/material.dart';

import 'ball_interface.dart';

class PendulumBall implements Ball {
  @override
  final int index;
  @override
  final Offset origin;
  @override
  Offset position;
  @override
  final double length;

  double angle;
  double angularVelocity;
  late Offset dragOffset;
  @override
  bool isDragging = false;
  @override
  bool isInCollision = false;

  // Physics constants
  final double gravity = 39.24;
  final double damping = 0.995;

  PendulumBall({
    required this.index,
    required this.origin,
    required this.position,
    required this.length,
  })  : angle = 0.0,
        angularVelocity = 0.0 {
    angle = atan2(position.dx - origin.dx, position.dy - origin.dy);
  }

  @override
  void update(double dt) {
    if (!isDragging) {
      final double angularAcceleration = -(gravity / length) * sin(angle);
      angularVelocity += angularAcceleration * dt * 4.0;
      angularVelocity *= damping;
      angle += angularVelocity * dt * 2.0;

      position = Offset(
        origin.dx + length * sin(angle),
        origin.dy + length * cos(angle),
      );
    }
  }

  @override
  void startDragging(Offset localPosition) {
    isDragging = true;
    dragOffset = localPosition - position;
    angularVelocity = 0;
  }

  @override
  void updateDragPosition(Offset newPosition) {
    if (!isDragging) return;

    final touchPos = newPosition - dragOffset;
    final dx = touchPos.dx - origin.dx;

    // Only allow horizontal movement
    double newAngle = atan2(dx, sqrt(length * length - dx * dx));
    newAngle = newAngle.clamp(-pi / 2, pi / 2); // Limit swing angle

    position = Offset(
      origin.dx + length * sin(newAngle),
      origin.dy + length * cos(newAngle),
    );
    angle = newAngle;
  }

  @override
  void endDragging() {
    isDragging = false;
  }

  @override
  bool isColliding(Ball other, double ballRadius) {
    final distance = (position - other.position).distance;
    final collisionDistance = ballRadius * 2.0;

    if (distance <= collisionDistance) {
      if (!isInCollision) {
        if (other is PendulumBall) {
          _handleCollision(other);
        }
        isInCollision = true;
        other.isInCollision = true;
        return true;
      }
    } else {
      isInCollision = false;
    }
    return false;
  }

  void _handleCollision(PendulumBall other) {
    final temp = angularVelocity;
    angularVelocity = other.angularVelocity;
    other.angularVelocity = temp;
  }

  @override
  double getLinearVelocity() {
    return angularVelocity * length;
  }

  @override
  void applyImpulse(double impulse) {
    angularVelocity = impulse / length;
  }
}

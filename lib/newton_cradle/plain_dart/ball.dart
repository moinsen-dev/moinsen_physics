import 'dart:math';

import 'package:flutter/material.dart';

class Ball {
  final int index;
  final Offset origin;
  Offset position;
  final double length;
  double angle;
  bool isDragging;
  double angularVelocity;
  late Offset dragOffset;

  // Significantly increased physics constants for much faster motion
  final double gravity = 39.24; // 4x normal gravity
  final double damping = 0.995; // Increased damping for faster energy loss

  Ball({
    required this.index,
    required this.origin,
    required this.position,
    required this.length,
  })  : angle = 0.0,
        isDragging = false,
        angularVelocity = 0.0;

  void update(double dt) {
    if (!isDragging) {
      // Pendulum physics with fixed rope length
      final double angularAcceleration = -(gravity / length) * sin(angle);

      // Greatly increased time scaling for much faster motion
      angularVelocity += angularAcceleration * dt * 4.0;
      angularVelocity *= damping;

      // Update angle with increased time scaling
      angle += angularVelocity * dt * 2.0;

      // Enforce fixed rope length by using circular motion
      position = Offset(
        origin.dx + length * sin(angle),
        origin.dy + length * cos(angle),
      );
    }
  }

  void setAngle(double newAngle) {
    angle = newAngle;

    // Enforce fixed rope length
    position = Offset(
      origin.dx + length * sin(angle),
      origin.dy + length * cos(angle),
    );
  }

  bool isColliding(Ball other, double ballRadius) {
    return (position - other.position).distance <= ballRadius * 2.0;
  }

  double getLinearVelocity() {
    // Convert angular velocity to linear velocity at the point of collision
    return angularVelocity * length;
  }

  void applyImpulse(double impulse) {
    // Convert linear impulse to angular velocity
    angularVelocity = impulse / length;
  }

  // Calculate the energy of the pendulum (for debugging)
  double getTotalEnergy() {
    // Kinetic energy + Potential energy
    double ke = 0.5 * angularVelocity * angularVelocity * length * length;
    double pe = gravity * length * (1 - cos(angle));
    return ke + pe;
  }

  void updateWithGravity(double dt, double gravityX, double gravityY) {
    if (!isDragging) {
      // Calculate forces including lateral movement
      final double dx = position.dx - origin.dx;
      final double dy = position.dy - origin.dy;
      final double currentLength = (position - origin).distance;

      // Calculate tension force to maintain rope length
      final double tensionMagnitude = (currentLength - length) * 100.0;
      final double tensionX = -dx / currentLength * tensionMagnitude;
      final double tensionY = -dy / currentLength * tensionMagnitude;

      // Apply gravity and tension forces
      double accelerationX = (gravityX + tensionX) / length;
      double accelerationY = (gravityY + tensionY) / length;

      // Update velocity
      angularVelocity += accelerationX * dt;

      // Apply damping
      angularVelocity *= damping;

      // Update position
      position = Offset(
        position.dx + angularVelocity * dt * length,
        origin.dy + length * cos(angle),
      );

      // Update angle based on new position
      angle = atan2(position.dx - origin.dx, position.dy - origin.dy);
    }
  }
}

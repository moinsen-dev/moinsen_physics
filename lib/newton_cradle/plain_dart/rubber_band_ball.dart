import 'dart:math';

import 'package:flutter/material.dart';

import 'ball_interface.dart';

class RubberBandBall implements Ball {
  @override
  final int index;
  @override
  final Offset origin;
  @override
  Offset position;
  @override
  final double length;

  late Offset dragOffset;
  @override
  bool isDragging = false;
  @override
  bool isInCollision = false;

  // Physics constants
  final double springConstant = 150.0;
  final double maxStretch = 2.0;
  final double dampingFactor = 0.99;
  final double gravity = 39.24;

  double velocityX = 0.0;
  double velocityY = 0.0;

  RubberBandBall({
    required this.index,
    required this.origin,
    required this.position,
    required this.length,
  });

  @override
  void update(double dt) {
    if (!isDragging) {
      final dx = position.dx - origin.dx;
      final dy = position.dy - origin.dy;
      final currentLength = sqrt(dx * dx + dy * dy);

      if (currentLength > 0) {
        final dirX = dx / currentLength;
        final dirY = dy / currentLength;

        double springForce = 0.0;
        if (currentLength > length) {
          springForce = -springConstant * (currentLength - length);
        }

        final forceX = springForce * dirX;
        final forceY = springForce * dirY + gravity;

        velocityX += forceX * dt;
        velocityY += forceY * dt;

        velocityX *= dampingFactor;
        velocityY *= dampingFactor;

        final newX = position.dx + velocityX * dt;
        final newY = position.dy + velocityY * dt;

        final newDx = newX - origin.dx;
        final newDy = newY - origin.dy;
        final newLength = sqrt(newDx * newDx + newDy * newDy);

        if (newLength > length * maxStretch) {
          position = Offset(
            origin.dx + (newDx / newLength) * length * maxStretch,
            origin.dy + (newDy / newLength) * length * maxStretch,
          );
          velocityX *= 0.5;
          velocityY *= 0.5;
        } else {
          position = Offset(newX, newY);
        }
      }
    }
  }

  @override
  void startDragging(Offset localPosition) {
    isDragging = true;
    dragOffset = localPosition - position;
    velocityX = 0;
    velocityY = 0;
  }

  @override
  void updateDragPosition(Offset newPosition) {
    if (!isDragging) return;
    position = newPosition - dragOffset;
  }

  @override
  void endDragging() {
    isDragging = false;
    final dx = position.dx - origin.dx;
    final dy = position.dy - origin.dy;
    final currentLength = sqrt(dx * dx + dy * dy);

    if (currentLength > length) {
      final stretch = currentLength - length;
      velocityX = -dx / currentLength * stretch * 2;
      velocityY = -dy / currentLength * stretch * 2;
    }
  }

  @override
  bool isColliding(Ball other, double ballRadius) {
    final distance = (position - other.position).distance;
    final collisionDistance = ballRadius * 2.0;

    if (distance <= collisionDistance) {
      if (!isInCollision) {
        if (other is RubberBandBall) {
          _handleCollision(other, ballRadius);
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

  void _handleCollision(RubberBandBall other, double ballRadius) {
    final dx = other.position.dx - position.dx;
    final dy = other.position.dy - position.dy;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist == 0) return;

    final nx = dx / dist;
    final ny = dy / dist;

    final dvx = other.velocityX - velocityX;
    final dvy = other.velocityY - velocityY;

    final normalVelocity = dvx * nx + dvy * ny;
    if (normalVelocity > 0) return;

    final restitution = 0.8;
    final impulse = -(1 + restitution) * normalVelocity / 2;

    velocityX -= impulse * nx;
    velocityY -= impulse * ny;
    other.velocityX += impulse * nx;
    other.velocityY += impulse * ny;

    // Separate overlapping balls
    final overlap = ballRadius * 2 - dist;
    if (overlap > 0) {
      final separationX = (overlap * nx) / 2;
      final separationY = (overlap * ny) / 2;
      position = Offset(position.dx - separationX, position.dy - separationY);
      other.position = Offset(
          other.position.dx + separationX, other.position.dy + separationY);
    }
  }

  @override
  double getLinearVelocity() {
    return sqrt(velocityX * velocityX + velocityY * velocityY);
  }

  @override
  void applyImpulse(double impulse) {
    final dx = position.dx - origin.dx;
    final dy = position.dy - origin.dy;
    final len = sqrt(dx * dx + dy * dy);

    velocityX += (impulse * dx / len);
    velocityY += (impulse * dy / len);
  }
}

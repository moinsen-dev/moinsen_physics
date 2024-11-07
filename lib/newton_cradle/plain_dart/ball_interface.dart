import 'package:flutter/material.dart';

// Base interface for all ball types
abstract class Ball {
  int get index;
  Offset get origin;
  Offset get position;
  set position(Offset value);
  double get length;
  bool get isDragging;
  bool get isInCollision;
  set isInCollision(bool value);

  void update(double dt);
  void startDragging(Offset localPosition);
  void updateDragPosition(Offset newPosition);
  void endDragging();
  bool isColliding(Ball other, double ballRadius);
  double getLinearVelocity();
  void applyImpulse(double impulse);
}

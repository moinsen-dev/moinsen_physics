import 'package:flutter/material.dart';

enum CradleVersion {
  classic,
  physics,
}

class SimulationControls {
  final int numberOfBalls;
  final double ballRadius;
  final double ropeLength;
  final Color ballColor;
  final double ballWeightGrams;
  final bool isSoundEnabled;
  final double soundVolume;
  final CradleVersion version;
  final bool useRubberBands;

  const SimulationControls({
    required this.numberOfBalls,
    required this.ballRadius,
    required this.ropeLength,
    required this.ballColor,
    required this.ballWeightGrams,
    required this.isSoundEnabled,
    required this.soundVolume,
    required this.version,
    required this.useRubberBands,
  });

  SimulationControls copyWith({
    int? numberOfBalls,
    double? ballRadius,
    double? ropeLength,
    Color? ballColor,
    double? ballWeightGrams,
    bool? isSoundEnabled,
    double? soundVolume,
    CradleVersion? version,
    bool? useRubberBands,
  }) {
    return SimulationControls(
      numberOfBalls: numberOfBalls ?? this.numberOfBalls,
      ballRadius: ballRadius ?? this.ballRadius,
      ropeLength: ropeLength ?? this.ropeLength,
      ballColor: ballColor ?? this.ballColor,
      ballWeightGrams: ballWeightGrams ?? this.ballWeightGrams,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      version: version ?? this.version,
      useRubberBands: useRubberBands ?? this.useRubberBands,
    );
  }

  static const defaultControls = SimulationControls(
    numberOfBalls: 5,
    ballRadius: 30.0,
    ropeLength: 200.0,
    ballColor: Colors.grey,
    ballWeightGrams: 100.0,
    isSoundEnabled: true,
    soundVolume: 0.5,
    version: CradleVersion.classic,
    useRubberBands: false,
  );
}

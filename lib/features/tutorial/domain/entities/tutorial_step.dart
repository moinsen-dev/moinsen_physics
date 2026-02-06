import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Represents a single step in the tutorial sequence
class TutorialStep {
  final String id;
  final String title;
  final String description;
  final TutorialAction action;
  final Vector2? highlightPosition;
  final double? highlightRadius;
  final bool canSkip;
  final Duration? autoProceedAfter;
  final List<String>? validationCriteria;
  
  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    required this.action,
    this.highlightPosition,
    this.highlightRadius,
    this.canSkip = true,
    this.autoProceedAfter,
    this.validationCriteria,
  });
  
  /// Check if the step has been completed based on game state
  bool isCompleted(Map<String, dynamic> gameState) {
    if (validationCriteria == null) return true;
    
    for (final criterion in validationCriteria!) {
      if (!_checkCriterion(criterion, gameState)) {
        return false;
      }
    }
    return true;
  }
  
  bool _checkCriterion(String criterion, Map<String, dynamic> gameState) {
    // Parse criterion and check against game state
    // Examples: "gravity_switched", "object_reached_goal", "time_elapsed:3"
    final parts = criterion.split(':');
    final type = parts[0];
    
    switch (type) {
      case 'gravity_switched':
        return gameState['gravity_switched'] == true;
      case 'object_reached_goal':
        return gameState['object_reached_goal'] == true;
      case 'time_elapsed':
        final requiredTime = double.parse(parts[1]);
        final elapsed = gameState['time_elapsed'] ?? 0.0;
        return elapsed >= requiredTime;
      default:
        return true;
    }
  }
}

/// Types of tutorial actions
enum TutorialAction {
  /// Show a text bubble with information
  showInfo,
  
  /// Highlight a specific area
  highlightArea,
  
  /// Show a ghost hand performing an action
  showGhostHand,
  
  /// Wait for player to perform an action
  waitForAction,
  
  /// Show an arrow pointing to something
  showArrow,
  
  /// Temporarily disable certain controls
  restrictControls,
  
  /// Show a mini cutscene
  showCutscene,
}

/// Tutorial sequence for a level
class TutorialSequence {
  final String levelId;
  final List<TutorialStep> steps;
  final bool isSkippable;
  final Map<String, dynamic> initialState;
  
  const TutorialSequence({
    required this.levelId,
    required this.steps,
    this.isSkippable = true,
    this.initialState = const {},
  });
  
  /// Get the next step based on current progress
  TutorialStep? getNextStep(int currentStepIndex, Map<String, dynamic> gameState) {
    if (currentStepIndex >= steps.length) return null;
    
    final currentStep = steps[currentStepIndex];
    if (currentStep.isCompleted(gameState)) {
      return getNextStep(currentStepIndex + 1, gameState);
    }
    
    return currentStep;
  }
}

/// Ghost hand animation data
class GhostHandAnimation {
  final Vector2 startPosition;
  final Vector2 endPosition;
  final Duration duration;
  final Curve curve;
  final GhostHandGesture gesture;
  
  const GhostHandAnimation({
    required this.startPosition,
    required this.endPosition,
    required this.duration,
    this.curve = Curves.easeInOut,
    this.gesture = GhostHandGesture.tap,
  });
}

enum GhostHandGesture {
  tap,
  drag,
  swipe,
  pinch,
  hold,
}
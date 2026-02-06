import 'package:flame_forge2d/flame_forge2d.dart';
import 'level.dart';
import '../../../game/presentation/components/gravity_lab_game.dart';

/// Additional victory conditions for advanced levels

/// Reach a specific target position
class ReachTargetCondition extends VictoryCondition {
  final Vector2 targetPosition;
  final double targetRadius;
  final List<String> requiredObjectIds;
  
  ReachTargetCondition({
    required this.targetPosition,
    required this.targetRadius,
    required this.requiredObjectIds,
  }) : super(type: 'reach_target');
  
  @override
  bool isMet(GameState gameState) {
    for (final objectId in requiredObjectIds) {
      final object = gameState.objects.firstWhere(
        (obj) => obj.hashCode.toString() == objectId,
        orElse: () => throw Exception('Object $objectId not found'),
      );
      
      final distance = (object.body.position - targetPosition).length;
      if (distance > targetRadius) {
        return false;
      }
    }
    return true;
  }
  
  @override
  double getProgress(GameState gameState) {
    double totalProgress = 0;
    
    for (final objectId in requiredObjectIds) {
      final object = gameState.objects.firstWhere(
        (obj) => obj.hashCode.toString() == objectId,
        orElse: () => throw Exception('Object $objectId not found'),
      );
      
      final distance = (object.body.position - targetPosition).length;
      final progress = 1.0 - (distance / 100).clamp(0, 1);
      totalProgress += progress;
    }
    
    return totalProgress / requiredObjectIds.length;
  }
  
  @override
  String get description => 'Guide objects to the target';
}

/// Complete level within time limit
class TimeCondition extends VictoryCondition {
  final double maxTime;
  
  TimeCondition({required this.maxTime}) : super(type: 'time_limit');
  
  @override
  bool isMet(GameState gameState) {
    return gameState.elapsedTime <= maxTime;
  }
  
  @override
  double getProgress(GameState gameState) {
    return (maxTime - gameState.elapsedTime) / maxTime;
  }
  
  @override
  String get description => 'Complete within ${maxTime.toInt()} seconds';
}

/// Destroy specific objects
class DestroyObjectsCondition extends VictoryCondition {
  final String targetTag;
  final int? requiredCount;
  
  DestroyObjectsCondition({
    required this.targetTag,
    this.requiredCount,
  }) : super(type: 'destroy_objects');
  
  @override
  bool isMet(GameState gameState) {
    final destroyed = gameState.customState['destroyed_$targetTag'] ?? 0;
    return requiredCount != null ? destroyed >= requiredCount : destroyed > 0;
  }
  
  @override
  double getProgress(GameState gameState) {
    if (requiredCount == null) return 0;
    final destroyed = gameState.customState['destroyed_$targetTag'] ?? 0;
    return (destroyed / requiredCount!).clamp(0, 1);
  }
  
  @override
  String get description => requiredCount != null
      ? 'Destroy $requiredCount $targetTag objects'
      : 'Destroy all $targetTag objects';
}

/// Maintain a condition for duration
class MaintainCondition extends VictoryCondition {
  final String condition;
  final double minValue;
  final double duration;
  
  MaintainCondition({
    required this.condition,
    required this.minValue,
    required this.duration,
  }) : super(type: 'maintain');
  
  @override
  bool isMet(GameState gameState) {
    final maintainTime = gameState.customState['maintain_time_$condition'] ?? 0.0;
    return maintainTime >= duration;
  }
  
  @override
  double getProgress(GameState gameState) {
    final maintainTime = gameState.customState['maintain_time_$condition'] ?? 0.0;
    return (maintainTime / duration).clamp(0, 1);
  }
  
  @override
  String get description => 'Maintain $condition above $minValue for ${duration}s';
}

/// Composite condition with AND/OR logic
class CompositeCondition extends VictoryCondition {
  final List<VictoryCondition> conditions;
  final bool requireAll;
  
  CompositeCondition({
    required this.conditions,
    this.requireAll = true,
  }) : super(type: 'composite');
  
  @override
  bool isMet(GameState gameState) {
    if (requireAll) {
      return conditions.every((condition) => condition.isMet(gameState));
    } else {
      return conditions.any((condition) => condition.isMet(gameState));
    }
  }
  
  @override
  double getProgress(GameState gameState) {
    final progresses = conditions.map((c) => c.getProgress(gameState));
    
    if (requireAll) {
      // For AND, return minimum progress
      return progresses.reduce((a, b) => a < b ? a : b);
    } else {
      // For OR, return maximum progress
      return progresses.reduce((a, b) => a > b ? a : b);
    }
  }
  
  @override
  String get description {
    final op = requireAll ? 'AND' : 'OR';
    return conditions.map((c) => c.description).join(' $op ');
  }
}

/// All balls must reach any goal
class AllBallsInGoalCondition extends VictoryCondition {
  AllBallsInGoalCondition() : super(
    type: 'all_balls_in_goal',
  );
  
  @override
  bool isMet(GameState state) {
    // For simple game state
    if (state is SimpleGameState) {
      return state.ballsInGoal >= state.totalBalls && state.totalBalls > 0;
    }
    return false;
  }
  
  @override
  double getProgress(GameState state) {
    if (state is SimpleGameState) {
      if (state.totalBalls == 0) return 0;
      return (state.ballsInGoal / state.totalBalls).clamp(0, 1);
    }
    return 0;
  }
  
  @override
  String get description => 'Get all balls into the goal';
}
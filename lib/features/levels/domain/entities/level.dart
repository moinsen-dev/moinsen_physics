import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../../game/domain/entities/quantum_game_object.dart';

/// Core level entity for Gravity Lab 2.0
class Level {
  final String id;
  final String name;
  final String description;
  final int worldId;
  final int levelNumber;
  final LevelDifficulty difficulty;
  final List<GameObjectSpawn> objects;
  final List<VictoryCondition> victoryConditions;
  final PhysicsConfig physicsConfig;
  final VisualTheme visualTheme;
  final List<PowerUp> availablePowerUps;
  final TimeLimit? timeLimit;
  final int maxStars;
  final StarThresholds? starThresholds;
  final List<String>? hints;
  final List<String>? tutorialSteps;
  final Map<String, dynamic> metadata;
  
  // Gameplay state
  int starsEarned = 0;
  bool isCompleted = false;
  bool isUnlocked = false;
  double bestTime = double.infinity;
  int attempts = 0;
  
  // Performance targets
  final int perfectMoves;
  final double perfectTime;
  
  Level({
    required this.id,
    required this.name,
    required this.description,
    required this.worldId,
    required this.levelNumber,
    required this.difficulty,
    required this.objects,
    required this.victoryConditions,
    required this.physicsConfig,
    required this.visualTheme,
    this.availablePowerUps = const [],
    this.timeLimit,
    this.maxStars = 3,
    this.starThresholds,
    this.hints,
    this.tutorialSteps,
    this.metadata = const {},
    this.perfectMoves = 10,
    this.perfectTime = 30.0,
  });
  
  /// Check if level is completed based on current game state
  bool checkVictory(GameState gameState) {
    return victoryConditions.every((condition) => condition.isMet(gameState));
  }
  
  /// Get the primary victory condition
  VictoryCondition get victoryCondition => victoryConditions.first;
  
  /// Calculate stars earned based on performance
  int calculateStars(double completionTime, int retries, double efficiency) {
    int stars = 0;
    
    // Base star for completion
    if (isCompleted) stars++;
    
    // Time-based star
    if (timeLimit != null && completionTime <= timeLimit!.goldTime) {
      stars++;
    } else if (timeLimit != null && completionTime <= timeLimit!.silverTime) {
      // Half star logic could go here
    }
    
    // Efficiency star (no retries, minimal moves)
    if (retries == 0 && efficiency > 0.8) {
      stars++;
    }
    
    return stars.clamp(0, maxStars);
  }
  
  /// Get level display name
  String get displayName => '$worldId-$levelNumber: $name';
  
  /// Check if level is boss level
  bool get isBossLevel => levelNumber % 5 == 0;
  
  /// Check if level is tutorial
  bool get isTutorial => worldId == 1 && levelNumber <= 5;
}

/// Spawn configuration for game objects
class GameObjectSpawn {
  final String objectType;
  final Vector2 position;
  final double rotation;
  final Map<String, dynamic> properties;
  final double spawnDelay;
  
  // Additional properties for main game
  String get type => objectType;
  Vector2 get size => Vector2(
    properties['width']?.toDouble() ?? 20.0,
    properties['height']?.toDouble() ?? 20.0,
  );
  double get angle => rotation;
  
  GameObjectSpawn({
    required this.objectType,
    required this.position,
    this.rotation = 0,
    this.properties = const {},
    this.spawnDelay = 0,
  });
  
  /// Create the actual game object
  QuantumGameObject createObject() {
    switch (objectType) {
      case 'ball':
        return QuantumBall(
          position: position,
          radius: properties['radius'] ?? 1.0,
          color: properties['color'] ?? Colors.green,
        );
      case 'cube':
        return MassThiefCube(
          position: position,
          size: properties['size'] ?? 2.0,
        );
      case 'balloon':
        return AntigravBalloon(
          position: position,
          radius: properties['radius'] ?? 1.5,
        );
      case 'energy':
        return EnergySphere(
          position: position,
          radius: properties['radius'] ?? 1.0,
        );
      case 'magnet':
        return MagneticBall(
          position: position,
          radius: properties['radius'] ?? 1.3,
          magnetStrength: properties['strength'] ?? 100.0,
        );
      case 'portal':
        return PortalOrb(
          position: position,
          radius: properties['radius'] ?? 2.0,
        );
      case 'ghost':
        return GhostOrb(
          position: position,
          radius: properties['radius'] ?? 1.2,
        );
      case 'timecrystal':
        return TimeCrystal(
          position: position,
          radius: properties['radius'] ?? 1.5,
          timeFieldRadius: properties['fieldRadius'] ?? 5.0,
        );
      default:
        throw Exception('Unknown object type: $objectType');
    }
  }
}

/// Victory condition for level completion
abstract class VictoryCondition {
  final String type;
  final Map<String, dynamic> parameters;
  
  VictoryCondition({required this.type, this.parameters = const {}});
  
  /// Check if this condition is met
  bool isMet(GameState gameState);
  
  /// Get progress towards this condition (0.0 to 1.0)
  double getProgress(GameState gameState);
  
  /// Get human-readable description
  String get description;
}

/// Reach a specific goal area
class ReachGoalCondition extends VictoryCondition {
  final Vector2 goalPosition;
  final double goalRadius;
  final String? requiredObjectType;
  
  ReachGoalCondition({
    required this.goalPosition,
    required this.goalRadius,
    this.requiredObjectType,
  }) : super(type: 'reach_goal');
  
  @override
  bool isMet(GameState gameState) {
    for (final object in gameState.objects) {
      if (requiredObjectType != null && object.objectType != requiredObjectType) {
        continue;
      }
      
      final distance = (object.body.position - goalPosition).length;
      if (distance <= goalRadius) {
        return true;
      }
    }
    return false;
  }
  
  @override
  double getProgress(GameState gameState) {
    double minDistance = double.infinity;
    
    for (final object in gameState.objects) {
      if (requiredObjectType != null && object.objectType != requiredObjectType) {
        continue;
      }
      
      final distance = (object.body.position - goalPosition).length;
      minDistance = distance < minDistance ? distance : minDistance;
    }
    
    return 1.0 - (minDistance / 100).clamp(0, 1);
  }
  
  @override
  String get description => requiredObjectType != null
      ? 'Get the $requiredObjectType to the goal'
      : 'Get any object to the goal';
}

/// Collect all collectibles
class CollectAllCondition extends VictoryCondition {
  final int requiredCount;
  
  CollectAllCondition({required this.requiredCount}) 
      : super(type: 'collect_all');
  
  @override
  bool isMet(GameState gameState) {
    return gameState.collectiblesCollected >= requiredCount;
  }
  
  @override
  double getProgress(GameState gameState) {
    return (gameState.collectiblesCollected / requiredCount).clamp(0, 1);
  }
  
  @override
  String get description => 'Collect all $requiredCount quantum orbs';
}

/// Survive for a duration
class SurviveCondition extends VictoryCondition {
  final double duration;
  
  SurviveCondition({required this.duration}) 
      : super(type: 'survive');
  
  @override
  bool isMet(GameState gameState) {
    return gameState.elapsedTime >= duration && gameState.playerAlive;
  }
  
  @override
  double getProgress(GameState gameState) {
    if (!gameState.playerAlive) return 0;
    return (gameState.elapsedTime / duration).clamp(0, 1);
  }
  
  @override
  String get description => 'Survive for ${duration.toInt()} seconds';
}

/// Physics configuration for the level
class PhysicsConfig {
  final Vector2 gravity;
  final double timeScale;
  final double bounciness;
  final double friction;
  final bool allowQuantumEffects;
  final bool allowTimeManipulation;
  final bool allowGravityPainting;
  final bool enableQuantumEffects;
  final bool enablePortals;
  final bool enableTimeCrystals;
  final List<dynamic> customGravityFields;
  final List<dynamic> environmentEffects;
  final Map<String, dynamic> customRules;
  
  PhysicsConfig({
    Vector2? gravity,
    this.timeScale = 1.0,
    this.bounciness = 0.5,
    this.friction = 0.3,
    this.allowQuantumEffects = true,
    this.allowTimeManipulation = true,
    this.allowGravityPainting = true,
    this.enableQuantumEffects = true,
    this.enablePortals = false,
    this.enableTimeCrystals = false,
    this.customGravityFields = const [],
    this.environmentEffects = const [],
    this.customRules = const {},
  }) : gravity = gravity ?? Vector2(0, 9.81);
}

/// Visual theme for the level
class VisualTheme {
  final String backgroundType;
  final List<Color> colorPalette;
  final String particleTheme;
  final double ambientIntensity;
  final List<String> specialEffects;
  
  VisualTheme({
    required this.backgroundType,
    required this.colorPalette,
    this.particleTheme = 'default',
    this.ambientIntensity = 1.0,
    this.specialEffects = const [],
  });
}

/// Time limits for star ratings
class TimeLimit {
  final double goldTime;
  final double silverTime;
  final double bronzeTime;
  
  TimeLimit({
    required this.goldTime,
    required this.silverTime,
    required this.bronzeTime,
  });
}

/// Power-ups available in the level
class PowerUp {
  final String type;
  final String name;
  final String description;
  final Duration duration;
  final Map<String, dynamic> effects;
  
  PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.duration,
    this.effects = const {},
  });
}

/// Current game state for victory checking
class GameState {
  final List<QuantumGameObject> objects;
  final double elapsedTime;
  final int collectiblesCollected;
  final bool playerAlive;
  final Map<String, dynamic> customState;
  
  GameState({
    required this.objects,
    required this.elapsedTime,
    this.collectiblesCollected = 0,
    this.playerAlive = true,
    this.customState = const {},
  });
}

/// Level difficulty enumeration
enum LevelDifficulty {
  tutorial,
  easy,
  medium,
  hard,
  expert,
  insane,
}

/// Star thresholds for level completion
class StarThresholds {
  final ThresholdRequirement oneStar;
  final ThresholdRequirement twoStars;
  final ThresholdRequirement threeStars;
  
  StarThresholds({
    required this.oneStar,
    required this.twoStars,
    required this.threeStars,
  });
}

/// Threshold requirement for stars
class ThresholdRequirement {
  final double timeLimit;
  final int minScore;
  final String? bonusObjective;
  final String? specialRequirement;
  
  ThresholdRequirement({
    required this.timeLimit,
    required this.minScore,
    this.bonusObjective,
    this.specialRequirement,
  });
}


import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'level.dart';

/// World entity representing a themed collection of levels
class World {
  final int id;
  final String name;
  final String description;
  final String theme;
  final WorldVisuals visuals;
  final List<Level> levels;
  final WorldUnlockRequirement unlockRequirement;
  final List<String> features;
  final BossInfo? bossInfo;
  final Map<String, dynamic> metadata;
  
  // Progress tracking
  int levelsCompleted = 0;
  int totalStarsEarned = 0;
  bool isUnlocked = false;
  bool bossDefeated = false;
  
  World({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    required this.visuals,
    required this.levels,
    required this.unlockRequirement,
    this.features = const [],
    this.bossInfo,
    this.metadata = const {},
  });
  
  /// Calculate world completion percentage
  double get completionPercentage {
    if (levels.isEmpty) return 0.0;
    return levelsCompleted / levels.length;
  }
  
  /// Get total possible stars in world
  int get totalPossibleStars => levels.length * 3;
  
  /// Check if world is fully completed
  bool get isCompleted => levelsCompleted == levels.length;
  
  /// Check if world can be unlocked
  bool checkUnlockStatus(GameProgress progress) {
    return unlockRequirement.isMet(progress);
  }
  
  /// Get next uncompleted level
  Level? get nextLevel {
    return levels.firstWhere(
      (level) => !level.isCompleted,
      orElse: () => levels.last,
    );
  }
  
  /// Get world difficulty description
  String get difficultyDescription {
    switch (id) {
      case 1: return 'Beginner Friendly';
      case 2: return 'Easy to Medium';
      case 3: return 'Medium';
      case 4: return 'Medium to Hard';
      case 5: return 'Hard';
      case 6: return 'Expert Only';
      default: return 'Unknown';
    }
  }
}

/// Visual configuration for a world
class WorldVisuals {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String backgroundAsset;
  final String musicTrack;
  final List<String> particleEffects;
  final Map<String, String> objectSkins;
  final LightingConfig lighting;
  
  WorldVisuals({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundAsset,
    required this.musicTrack,
    this.particleEffects = const [],
    this.objectSkins = const {},
    required this.lighting,
  });
}

/// Lighting configuration for world atmosphere
class LightingConfig {
  final Color ambientColor;
  final double ambientIntensity;
  final List<LightSource> lights;
  final bool enableShadows;
  final bool enableBloom;
  
  LightingConfig({
    required this.ambientColor,
    required this.ambientIntensity,
    this.lights = const [],
    this.enableShadows = true,
    this.enableBloom = true,
  });
}

/// Individual light source
class LightSource {
  final Vector2 position;
  final Color color;
  final double intensity;
  final double radius;
  final LightType type;
  
  LightSource({
    required this.position,
    required this.color,
    required this.intensity,
    required this.radius,
    required this.type,
  });
}

enum LightType {
  point,
  directional,
  spot,
  area,
}

/// Requirements to unlock a world
abstract class WorldUnlockRequirement {
  bool isMet(GameProgress progress);
  String get description;
}

/// Unlock by completing previous world
class PreviousWorldRequirement extends WorldUnlockRequirement {
  final int requiredWorldId;
  final double requiredCompletion;
  
  PreviousWorldRequirement({
    required this.requiredWorldId,
    this.requiredCompletion = 1.0,
  });
  
  @override
  bool isMet(GameProgress progress) {
    final world = progress.getWorld(requiredWorldId);
    if (world == null) return false;
    return world.completionPercentage >= requiredCompletion;
  }
  
  @override
  String get description => 
      'Complete ${(requiredCompletion * 100).toInt()}% of World $requiredWorldId';
}

/// Unlock by earning stars
class StarRequirement extends WorldUnlockRequirement {
  final int requiredStars;
  
  StarRequirement({required this.requiredStars});
  
  @override
  bool isMet(GameProgress progress) {
    return progress.totalStarsEarned >= requiredStars;
  }
  
  @override
  String get description => 'Earn $requiredStars stars';
}

/// Unlock by defeating a boss
class BossRequirement extends WorldUnlockRequirement {
  final int bossWorldId;
  
  BossRequirement({required this.bossWorldId});
  
  @override
  bool isMet(GameProgress progress) {
    final world = progress.getWorld(bossWorldId);
    return world?.bossDefeated ?? false;
  }
  
  @override
  String get description => 'Defeat the boss of World $bossWorldId';
}

/// Combined requirements
class CompositeRequirement extends WorldUnlockRequirement {
  final List<WorldUnlockRequirement> requirements;
  final bool requireAll;
  
  CompositeRequirement({
    required this.requirements,
    this.requireAll = true,
  });
  
  @override
  bool isMet(GameProgress progress) {
    if (requireAll) {
      return requirements.every((req) => req.isMet(progress));
    } else {
      return requirements.any((req) => req.isMet(progress));
    }
  }
  
  @override
  String get description {
    final connector = requireAll ? ' AND ' : ' OR ';
    return requirements.map((r) => r.description).join(connector);
  }
}

/// Boss information for worlds with bosses
class BossInfo {
  final String name;
  final String description;
  final String spriteAsset;
  final List<String> abilities;
  final Map<String, dynamic> battleConfig;
  
  BossInfo({
    required this.name,
    required this.description,
    required this.spriteAsset,
    required this.abilities,
    this.battleConfig = const {},
  });
}

/// Player's overall game progress
class GameProgress {
  final Map<int, World> worlds;
  int totalStarsEarned = 0;
  int totalLevelsCompleted = 0;
  
  GameProgress({required this.worlds});
  
  World? getWorld(int id) => worlds[id];
  
  void updateProgress() {
    totalStarsEarned = 0;
    totalLevelsCompleted = 0;
    
    for (final world in worlds.values) {
      totalStarsEarned += world.totalStarsEarned;
      totalLevelsCompleted += world.levelsCompleted;
    }
  }
}


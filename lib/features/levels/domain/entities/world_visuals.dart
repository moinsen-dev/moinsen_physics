import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Visual configuration for game worlds
class WorldVisuals {
  final Color backgroundColor;
  final String backgroundImage;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double fogDensity;
  final Color fogColor;
  final LightingConfig lighting;
  final List<ParticleEffect> ambientParticles;
  final EnvironmentSounds sounds;
  
  const WorldVisuals({
    required this.backgroundColor,
    required this.backgroundImage,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.fogDensity = 0.0,
    this.fogColor = Colors.white,
    required this.lighting,
    this.ambientParticles = const [],
    required this.sounds,
  });
}

/// Lighting configuration for a world
class LightingConfig {
  final Color ambientColor;
  final double ambientIntensity;
  final List<LightSource> lightSources;
  final bool hasShadows;
  final double shadowOpacity;
  
  const LightingConfig({
    required this.ambientColor,
    required this.ambientIntensity,
    this.lightSources = const [],
    this.hasShadows = false,
    this.shadowOpacity = 0.5,
  });
}

/// Individual light source
class LightSource {
  final Vector2 position;
  final Color color;
  final double intensity;
  final double radius;
  final LightType type;
  final bool castsShadows;
  
  const LightSource({
    required this.position,
    required this.color,
    required this.intensity,
    required this.radius,
    required this.type,
    this.castsShadows = true,
  });
}

/// Types of light sources
enum LightType {
  point,
  directional,
  spot,
  ambient,
  area,
}

/// Particle effect configuration
class ParticleEffect {
  final String type;
  final Color color;
  final double density;
  final double speed;
  final double size;
  
  const ParticleEffect({
    required this.type,
    required this.color,
    this.density = 1.0,
    this.speed = 1.0,
    this.size = 1.0,
  });
}

/// Environment sound configuration
class EnvironmentSounds {
  final String ambientMusic;
  final double musicVolume;
  final List<String> ambientSounds;
  final double soundVolume;
  
  const EnvironmentSounds({
    required this.ambientMusic,
    this.musicVolume = 0.7,
    this.ambientSounds = const [],
    this.soundVolume = 0.5,
  });
}

/// World unlock requirements
abstract class WorldUnlockRequirement {
  bool isSatisfied(PlayerProgress progress);
}

/// Requires completing previous world
class PreviousWorldRequirement extends WorldUnlockRequirement {
  final int previousWorldId;
  final double completionPercentage;
  
  PreviousWorldRequirement({
    required this.previousWorldId,
    this.completionPercentage = 0.8,
  });
  
  @override
  bool isSatisfied(PlayerProgress progress) {
    final worldProgress = progress.worldProgress[previousWorldId];
    if (worldProgress == null) return false;
    
    final completedLevels = worldProgress.completedLevels.length;
    final totalLevels = 20; // Each world has 20 levels
    
    return (completedLevels / totalLevels) >= completionPercentage;
  }
}

/// Requires certain number of stars
class StarRequirement extends WorldUnlockRequirement {
  final int requiredStars;
  
  StarRequirement({required this.requiredStars});
  
  @override
  bool isSatisfied(PlayerProgress progress) {
    return progress.totalStars >= requiredStars;
  }
}

/// Requires defeating a boss
class BossRequirement extends WorldUnlockRequirement {
  final String bossId;
  
  BossRequirement({required this.bossId});
  
  @override
  bool isSatisfied(PlayerProgress progress) {
    return progress.defeatedBosses.contains(bossId);
  }
}

/// Composite requirement (AND/OR logic)
class CompositeRequirement extends WorldUnlockRequirement {
  final List<WorldUnlockRequirement> requirements;
  final bool requireAll;
  
  CompositeRequirement({
    required this.requirements,
    this.requireAll = true,
  });
  
  @override
  bool isSatisfied(PlayerProgress progress) {
    if (requireAll) {
      return requirements.every((req) => req.isSatisfied(progress));
    } else {
      return requirements.any((req) => req.isSatisfied(progress));
    }
  }
}

/// Boss information
class BossInfo {
  final String id;
  final String name;
  final String description;
  final int health;
  final List<String> attacks;
  final Map<String, dynamic> specialMechanics;
  
  const BossInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.health,
    required this.attacks,
    this.specialMechanics = const {},
  });
}

/// Player progress tracking
class PlayerProgress {
  final Map<int, WorldProgress> worldProgress;
  final int totalStars;
  final Set<String> defeatedBosses;
  final Map<String, dynamic> achievements;
  
  const PlayerProgress({
    required this.worldProgress,
    required this.totalStars,
    required this.defeatedBosses,
    this.achievements = const {},
  });
}

/// World-specific progress
class WorldProgress {
  final int worldId;
  final Set<int> completedLevels;
  final Map<int, int> levelStars;
  final bool bossDefeated;
  
  const WorldProgress({
    required this.worldId,
    required this.completedLevels,
    required this.levelStars,
    this.bossDefeated = false,
  });
}
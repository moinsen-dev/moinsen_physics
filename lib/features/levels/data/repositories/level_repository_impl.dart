import 'dart:convert';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/world.dart' as game_world;
import '../../domain/repositories/level_repository.dart';
import '../../../progress/progress_service.dart';

/// Implementation of level repository for loading and managing levels
class LevelRepositoryImpl implements LevelRepository {
  final Map<int, game_world.World> _worldsCache = {};
  final Map<String, Level> _levelsCache = {};
  final ProgressService _progressService;
  
  LevelRepositoryImpl({required ProgressService progressService}) : _progressService = progressService;
  
  @override
  Future<List<game_world.World>> loadAllWorlds() async {
    if (_worldsCache.isNotEmpty) {
      return _worldsCache.values.toList();
    }
    
    // Load worlds configuration
    final worldsData = await rootBundle.loadString('assets/levels/worlds.json');
    final worldsJson = json.decode(worldsData) as Map<String, dynamic>;
    
    final worlds = <game_world.World>[];
    
    for (final worldData in worldsJson['worlds']) {
      final world = await _loadWorld(worldData);
      worlds.add(world);
      _worldsCache[world.id] = world;
    }
    
    // Check and update world unlock status
    _progressService.checkWorldUnlocks(worlds);
    
    // Update each world's unlock status from progress service
    for (final world in worlds) {
      world.isUnlocked = _progressService.isWorldUnlocked(world.id);
      
      // Also update progress data if available
      final worldProgress = _progressService.getWorldProgress(world.id);
      if (worldProgress != null) {
        world.levelsCompleted = worldProgress.levelsCompleted;
        world.totalStarsEarned = worldProgress.starsEarned;
        world.bossDefeated = worldProgress.bossDefeated;
      }
    }
    
    return worlds;
  }
  
  @override
  Future<game_world.World> loadWorld(int worldId) async {
    if (_worldsCache.containsKey(worldId)) {
      return _worldsCache[worldId]!;
    }
    
    final worldsData = await rootBundle.loadString('assets/levels/worlds.json');
    final worldsJson = json.decode(worldsData) as Map<String, dynamic>;
    
    final worldData = (worldsJson['worlds'] as List).firstWhere(
      (w) => w['id'] == worldId,
      orElse: () => throw Exception('World $worldId not found'),
    );
    
    final world = await _loadWorld(worldData);
    _worldsCache[worldId] = world;
    
    // Update unlock status from progress service
    world.isUnlocked = _progressService.isWorldUnlocked(world.id);
    
    // Update progress data if available
    final worldProgress = _progressService.getWorldProgress(world.id);
    if (worldProgress != null) {
      world.levelsCompleted = worldProgress.levelsCompleted;
      world.totalStarsEarned = worldProgress.starsEarned;
      world.bossDefeated = worldProgress.bossDefeated;
    }
    
    return world;
  }
  
  @override
  Future<Level> loadLevel(String levelId) async {
    if (_levelsCache.containsKey(levelId)) {
      return _levelsCache[levelId]!;
    }
    
    // Parse level ID (format: "1-5" for world 1, level 5)
    final parts = levelId.split('-');
    final worldId = int.parse(parts[0]);
    final levelNumber = int.parse(parts[1]);
    
    final levelPath = 'assets/levels/world_${worldId}_${_getWorldFolder(worldId)}/levels/level_${levelNumber.toString().padLeft(2, '0')}.json';
    final levelData = await rootBundle.loadString(levelPath);
    final levelJson = json.decode(levelData) as Map<String, dynamic>;
    
    final level = _parseLevel(levelJson, worldId, levelNumber);
    _levelsCache[levelId] = level;
    
    // Update level progress from progress service
    final levelProgress = _progressService.getLevelProgress(levelId);
    if (levelProgress != null) {
      level.isCompleted = levelProgress.isCompleted;
      level.starsEarned = levelProgress.starsEarned;
      level.bestTime = levelProgress.bestTime;
      level.attempts = levelProgress.attempts;
    }
    
    return level;
  }
  
  @override
  Future<void> saveProgress(String levelId, int stars, double time) async {
    final level = _levelsCache[levelId];
    if (level != null) {
      level.starsEarned = stars;
      level.bestTime = time < level.bestTime ? time : level.bestTime;
      level.isCompleted = true;
      level.attempts++;
      
      // Update progress service
      _progressService.updateLevelProgress(levelId, stars, time, true);
      
      // Update world progress
      final worldId = level.worldId;
      final world = _worldsCache[worldId];
      if (world != null) {
        world.levelsCompleted = world.levels.where((l) => l.isCompleted).length;
        world.totalStarsEarned = world.levels.fold(0, (sum, l) => sum + l.starsEarned);
        
        // Check if any new worlds should be unlocked
        _progressService.checkWorldUnlocks(_worldsCache.values.toList());
      }
    }
    
    // Save progress
    await _progressService.saveProgress();
  }
  
  @override
  Future<Map<String, dynamic>> loadLevelProgress() async {
    // TODO: Load from local storage
    return {};
  }
  
  Future<game_world.World> _loadWorld(Map<String, dynamic> worldData) async {
    final worldId = worldData['id'] as int;
    final levels = <Level>[];
    
    // Load all levels for this world
    final levelCount = worldData['levelCount'] ?? 20;
    for (int i = 1; i <= levelCount; i++) {
      try {
        final levelId = '$worldId-$i';
        final level = await loadLevel(levelId);
        levels.add(level);
      } catch (e) {
        print('Failed to load level $worldId-$i: $e');
      }
    }
    
    return game_world.World(
      id: worldId,
      name: worldData['name'],
      description: worldData['description'],
      theme: worldData['theme'],
      visuals: _parseWorldVisuals(worldData['visuals']),
      levels: levels,
      unlockRequirement: _parseUnlockRequirement(worldData['unlockRequirement']),
      features: List<String>.from(worldData['features'] ?? []),
      bossInfo: worldData['bossInfo'] != null 
          ? _parseBossInfo(worldData['bossInfo'])
          : null,
      metadata: worldData['metadata'] ?? {},
    );
  }
  
  Level _parseLevel(Map<String, dynamic> json, int worldId, int levelNumber) {
    return Level(
      id: '$worldId-$levelNumber',
      name: json['name'],
      description: json['description'],
      worldId: worldId,
      levelNumber: levelNumber,
      difficulty: _parseDifficulty(json['difficulty']),
      objects: _parseObjects(json['objects']),
      victoryConditions: _parseVictoryConditions(json['victoryConditions']),
      physicsConfig: _parsePhysicsConfig(json['physicsConfig']),
      visualTheme: _parseVisualTheme(json['visualTheme']),
      availablePowerUps: _parsePowerUps(json['powerUps'] ?? []),
      timeLimit: json['timeLimit'] != null 
          ? _parseTimeLimit(json['timeLimit'])
          : null,
      maxStars: json['maxStars'] ?? 3,
      metadata: json['metadata'] ?? {},
    );
  }
  
  List<GameObjectSpawn> _parseObjects(List<dynamic> objectsData) {
    return objectsData.map((obj) {
      return GameObjectSpawn(
        objectType: obj['type'],
        position: Vector2(
          (obj['position']['x'] as num).toDouble(),
          (obj['position']['y'] as num).toDouble(),
        ),
        rotation: (obj['rotation'] ?? 0).toDouble(),
        properties: obj['properties'] ?? {},
        spawnDelay: (obj['spawnDelay'] ?? 0).toDouble(),
      );
    }).toList();
  }
  
  List<VictoryCondition> _parseVictoryConditions(List<dynamic> conditionsData) {
    return conditionsData.map((condition) {
      final type = condition['type'] as String;
      
      switch (type) {
        case 'reach_goal':
          return ReachGoalCondition(
            goalPosition: Vector2(
              (condition['position']['x'] as num).toDouble(),
              (condition['position']['y'] as num).toDouble(),
            ),
            goalRadius: (condition['radius'] as num).toDouble(),
            requiredObjectType: condition['requiredObject'],
          );
          
        case 'collect_all':
          return CollectAllCondition(
            requiredCount: condition['count'] as int,
          );
          
        case 'survive':
          return SurviveCondition(
            duration: (condition['duration'] as num).toDouble(),
          );
          
        default:
          throw Exception('Unknown victory condition type: $type');
      }
    }).toList();
  }
  
  PhysicsConfig _parsePhysicsConfig(Map<String, dynamic> config) {
    return PhysicsConfig(
      gravity: config['gravity'] != null
          ? Vector2(
              (config['gravity']['x'] as num).toDouble(),
              (config['gravity']['y'] as num).toDouble(),
            )
          : null,
      timeScale: (config['timeScale'] ?? 1.0).toDouble(),
      bounciness: (config['bounciness'] ?? 0.5).toDouble(),
      friction: (config['friction'] ?? 0.3).toDouble(),
      allowQuantumEffects: config['allowQuantumEffects'] ?? true,
      allowTimeManipulation: config['allowTimeManipulation'] ?? true,
      allowGravityPainting: config['allowGravityPainting'] ?? true,
      customRules: config['customRules'] ?? {},
    );
  }
  
  VisualTheme _parseVisualTheme(Map<String, dynamic> theme) {
    return VisualTheme(
      backgroundType: theme['backgroundType'],
      colorPalette: (theme['colors'] as List).map((c) {
        return Color(int.parse(c.toString().substring(1), radix: 16) + 0xFF000000);
      }).toList(),
      particleTheme: theme['particleTheme'] ?? 'default',
      ambientIntensity: (theme['ambientIntensity'] ?? 1.0).toDouble(),
      specialEffects: List<String>.from(theme['specialEffects'] ?? []),
    );
  }
  
  TimeLimit _parseTimeLimit(Map<String, dynamic> limit) {
    return TimeLimit(
      goldTime: (limit['gold'] as num).toDouble(),
      silverTime: (limit['silver'] as num).toDouble(),
      bronzeTime: (limit['bronze'] as num).toDouble(),
    );
  }
  
  List<PowerUp> _parsePowerUps(List<dynamic> powerUpsData) {
    return powerUpsData.map((pu) {
      return PowerUp(
        type: pu['type'],
        name: pu['name'],
        description: pu['description'],
        duration: Duration(seconds: pu['duration'] ?? 30),
        effects: pu['effects'] ?? {},
      );
    }).toList();
  }
  
  LevelDifficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'tutorial': return LevelDifficulty.tutorial;
      case 'easy': return LevelDifficulty.easy;
      case 'medium': return LevelDifficulty.medium;
      case 'hard': return LevelDifficulty.hard;
      case 'expert': return LevelDifficulty.expert;
      case 'insane': return LevelDifficulty.insane;
      default: return LevelDifficulty.medium;
    }
  }
  
  game_world.WorldVisuals _parseWorldVisuals(Map<String, dynamic> visuals) {
    return game_world.WorldVisuals(
      primaryColor: Color(int.parse(visuals['primaryColor'].toString().substring(1), radix: 16) + 0xFF000000),
      secondaryColor: Color(int.parse(visuals['secondaryColor'].toString().substring(1), radix: 16) + 0xFF000000),
      accentColor: Color(int.parse(visuals['accentColor'].toString().substring(1), radix: 16) + 0xFF000000),
      backgroundAsset: visuals['backgroundAsset'],
      musicTrack: visuals['musicTrack'],
      particleEffects: List<String>.from(visuals['particleEffects'] ?? []),
      objectSkins: Map<String, String>.from(visuals['objectSkins'] ?? {}),
      lighting: _parseLightingConfig(visuals['lighting']),
    );
  }
  
  game_world.LightingConfig _parseLightingConfig(Map<String, dynamic> lighting) {
    return game_world.LightingConfig(
      ambientColor: Color(int.parse(lighting['ambientColor'].toString().substring(1), radix: 16) + 0xFF000000),
      ambientIntensity: (lighting['ambientIntensity'] ?? 1.0).toDouble(),
      lights: (lighting['lights'] as List? ?? []).map((light) {
        return game_world.LightSource(
          position: Vector2(
            (light['position']['x'] as num).toDouble(),
            (light['position']['y'] as num).toDouble(),
          ),
          color: Color(int.parse(light['color'].toString().substring(1), radix: 16) + 0xFF000000),
          intensity: (light['intensity'] as num).toDouble(),
          radius: (light['radius'] as num).toDouble(),
          type: _parseLightType(light['type']),
        );
      }).toList(),
      enableShadows: lighting['enableShadows'] ?? true,
      enableBloom: lighting['enableBloom'] ?? true,
    );
  }
  
  game_world.LightType _parseLightType(String type) {
    switch (type) {
      case 'point': return game_world.LightType.point;
      case 'directional': return game_world.LightType.directional;
      case 'spot': return game_world.LightType.spot;
      case 'area': return game_world.LightType.area;
      default: return game_world.LightType.point;
    }
  }
  
  game_world.WorldUnlockRequirement _parseUnlockRequirement(Map<String, dynamic> req) {
    final type = req['type'] as String;
    
    switch (type) {
      case 'previous_world':
        return game_world.PreviousWorldRequirement(
          requiredWorldId: req['worldId'],
          requiredCompletion: (req['completion'] ?? 1.0).toDouble(),
        );
        
      case 'stars':
        return game_world.StarRequirement(requiredStars: req['count']);
        
      case 'boss':
        return game_world.BossRequirement(bossWorldId: req['worldId']);
        
      case 'composite':
        return game_world.CompositeRequirement(
          requirements: (req['requirements'] as List)
              .map((r) => _parseUnlockRequirement(r))
              .toList(),
          requireAll: req['requireAll'] ?? true,
        );
        
      default:
        throw Exception('Unknown unlock requirement type: $type');
    }
  }
  
  game_world.BossInfo? _parseBossInfo(Map<String, dynamic> bossData) {
    return game_world.BossInfo(
      name: bossData['name'],
      description: bossData['description'],
      spriteAsset: bossData['spriteAsset'],
      abilities: List<String>.from(bossData['abilities'] ?? []),
      battleConfig: bossData['battleConfig'] ?? {},
    );
  }
  
  String _getWorldFolder(int worldId) {
    switch (worldId) {
      case 1: return 'newtons_laboratory';
      case 2: return 'zero_gravity_station';
      case 3: return 'quantum_realm';
      case 4: return 'time_laboratory';
      case 5: return 'magnetic_fields';
      case 6: return 'chaos_dimension';
      default: return 'unknown';
    }
  }
}
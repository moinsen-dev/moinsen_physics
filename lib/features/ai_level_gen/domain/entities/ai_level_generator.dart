import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../../levels/domain/entities/level.dart';
import '../../../levels/domain/entities/victory_conditions.dart';
import '../../../../core/physics/quantum_physics_engine.dart';

/// Revolutionary AI-powered level generator using GPT-4
/// Creates unique, challenging, and fun physics puzzles
class AILevelGenerator {
  static const String gpt4ApiEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  final Random _random = Random();
  
  /// Generate a level using AI with natural language description
  Future<Level> generateLevel({
    required String prompt,
    required int worldId,
    required int difficulty,
    List<String>? requiredElements,
    String? theme,
  }) async {
    // Create enhanced prompt for GPT-4
    final enhancedPrompt = _buildEnhancedPrompt(
      userPrompt: prompt,
      worldId: worldId,
      difficulty: difficulty,
      requiredElements: requiredElements,
      theme: theme,
    );
    
    // For now, use procedural generation with AI-inspired logic
    // In production, this would call GPT-4 API
    return _generateProceduralLevel(
      prompt: enhancedPrompt,
      worldId: worldId,
      difficulty: difficulty,
    );
  }
  
  /// Generate a complete world of levels with AI
  Future<List<Level>> generateWorld({
    required String worldTheme,
    required int worldId,
    int levelCount = 20,
  }) async {
    final levels = <Level>[];
    
    // Progressive difficulty curve
    for (int i = 0; i < levelCount; i++) {
      final difficulty = (i / levelCount * 10).round().clamp(1, 10);
      final isSpecialLevel = (i + 1) % 5 == 0; // Every 5th level is special
      
      final level = await generateLevel(
        prompt: _generateLevelPrompt(
          worldTheme: worldTheme,
          levelNumber: i + 1,
          isSpecial: isSpecialLevel,
        ),
        worldId: worldId,
        difficulty: difficulty,
        theme: worldTheme,
      );
      
      levels.add(level);
    }
    
    return levels;
  }
  
  /// Generate level from player's sketch or description
  Future<Level> generateFromSketch({
    required List<SketchElement> sketch,
    required String description,
    required int worldId,
  }) async {
    // Analyze sketch elements
    final analysis = _analyzeSketch(sketch);
    
    // Combine with natural language description
    final prompt = '''
    Create a physics puzzle level based on this sketch:
    - ${analysis.objectCount} objects detected
    - Main mechanics: ${analysis.mechanics.join(', ')}
    - User description: "$description"
    - Ensure the level is solvable and fun
    ''';
    
    return generateLevel(
      prompt: prompt,
      worldId: worldId,
      difficulty: analysis.estimatedDifficulty,
      requiredElements: analysis.detectedElements,
    );
  }
  
  String _buildEnhancedPrompt({
    required String userPrompt,
    required int worldId,
    required int difficulty,
    List<String>? requiredElements,
    String? theme,
  }) {
    return '''
    Design a Gravity Lab 2.0 physics puzzle level:
    
    User Request: $userPrompt
    
    Requirements:
    - World: ${_getWorldName(worldId)} (Theme: ${theme ?? 'default'})
    - Difficulty: $difficulty/10
    - Physics objects types available: ball, cube, balloon, magnet, energy_sphere, portal, time_crystal
    - Gravity can be manipulated in 8 directions
    - Include quantum mechanics like superposition and time manipulation
    
    ${requiredElements != null ? 'Must include: ${requiredElements.join(', ')}' : ''}
    
    Level should be:
    - Solvable within 2-5 minutes
    - Visually interesting with particle effects
    - Using unique physics interactions
    - Rewarding to complete
    
    Output format: JSON with objects, goals, and physics parameters
    ''';
  }
  
  Level _generateProceduralLevel({
    required String prompt,
    required int worldId,
    required int difficulty,
  }) {
    final objects = _generateObjects(difficulty);
    final goals = _generateGoals(objects, difficulty);
    final physicsConfig = _generatePhysicsConfig(worldId, difficulty);
    final levelLayout = _generateLayout(objects, goals, difficulty);
    
    return Level(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      worldId: worldId,
      levelNumber: _random.nextInt(20) + 1,
      name: _generateLevelName(prompt),
      description: _generateDescription(prompt, difficulty),
      difficulty: _difficultyToEnum(difficulty),
      victoryConditions: goals,
      physicsConfig: physicsConfig,
      objects: _convertToGameObjectSpawns(objects),
      visualTheme: _generateVisualTheme(worldId),
      starThresholds: _calculateStarThresholds(difficulty),
      hints: _generateHints(objects, goals),
      tutorialSteps: difficulty <= 3 ? _generateTutorial(objects, goals) : [],
    );
  }
  
  List<LevelObject> _generateObjects(int difficulty) {
    final objects = <LevelObject>[];
    final objectCount = 3 + (difficulty / 2).round();
    
    // Always have at least one interactive object
    objects.add(LevelObject(
      id: 'player_ball',
      type: 'ball',
      position: Vector2(-5, 0),
      properties: {
        'radius': 1.0,
        'color': Colors.green.toARGB32(),
        'isControllable': true,
      },
    ));
    
    // Add variety based on difficulty
    final availableTypes = [
      'ball', 'cube', 'balloon', 'magnet',
      if (difficulty > 5) 'energy_sphere',
      if (difficulty > 7) 'portal',
      if (difficulty > 8) 'time_crystal',
    ];
    
    for (int i = 1; i < objectCount; i++) {
      final type = availableTypes[_random.nextInt(availableTypes.length)];
      final position = _generatePosition(objects, i);
      
      objects.add(LevelObject(
        id: '${type}_$i',
        type: type,
        position: position,
        properties: _generateObjectProperties(type, difficulty),
      ));
    }
    
    return objects;
  }
  
  List<VictoryCondition> _generateGoals(List<LevelObject> objects, int difficulty) {
    final goals = <VictoryCondition>[];
    
    // Basic goal: reach target
    goals.add(ReachTargetCondition(
      targetPosition: Vector2(5, 0),
      targetRadius: 2.0,
      requiredObjectIds: ['player_ball'],
    ));
    
    // Add complexity based on difficulty
    if (difficulty > 3) {
      goals.add(CollectAllCondition(
        requiredCount: 3 + difficulty ~/ 2,
      ));
    }
    
    if (difficulty > 6) {
      goals.add(TimeCondition(
        maxTime: 60.0 + (difficulty * 10),
      ));
    }
    
    if (difficulty > 8) {
      goals.add(CompositeCondition(
        conditions: [
          DestroyObjectsCondition(targetTag: 'enemy'),
          MaintainCondition(
            condition: 'energy',
            minValue: 50.0,
            duration: 5.0,
          ),
        ],
        requireAll: true,
      ));
    }
    
    return goals;
  }
  
  PhysicsConfig _generatePhysicsConfig(int worldId, int difficulty) {
    final baseGravity = _getWorldBaseGravity(worldId);
    
    return PhysicsConfig(
      gravity: baseGravity,
      timeScale: 1.0,
      enableQuantumEffects: difficulty > 5,
      enablePortals: difficulty > 7,
      enableTimeCrystals: difficulty > 8,
      customGravityFields: difficulty > 4 ? _generateGravityFields(difficulty) : [],
      environmentEffects: _getWorldEnvironmentEffects(worldId),
    );
  }
  
  Map<String, dynamic> _generateLayout(
    List<LevelObject> objects,
    List<VictoryCondition> goals,
    int difficulty,
  ) {
    return {
      'boundary': {
        'width': 20.0 + (difficulty * 2),
        'height': 15.0 + difficulty,
      },
      'obstacles': _generateObstacles(difficulty),
      'decorations': _generateDecorations(difficulty),
      'particleEffects': _generateParticleEffects(difficulty),
    };
  }
  
  Vector2 _generatePosition(List<LevelObject> existingObjects, int index) {
    // Smart positioning to avoid overlaps
    const maxAttempts = 100;
    const minDistance = 2.0;
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final x = (_random.nextDouble() - 0.5) * 10;
      final y = (_random.nextDouble() - 0.5) * 8;
      final position = Vector2(x, y);
      
      bool validPosition = true;
      for (final obj in existingObjects) {
        if ((obj.position - position).length < minDistance) {
          validPosition = false;
          break;
        }
      }
      
      if (validPosition) return position;
    }
    
    // Fallback position
    return Vector2(index * 2.0, 0);
  }
  
  Map<String, dynamic> _generateObjectProperties(String type, int difficulty) {
    final properties = <String, dynamic>{};
    
    switch (type) {
      case 'ball':
        properties['radius'] = 0.5 + _random.nextDouble() * 1.0;
        properties['color'] = Colors.primaries[_random.nextInt(Colors.primaries.length)].toARGB32();
        properties['mass'] = 1.0 + _random.nextDouble() * 2.0;
        break;
        
      case 'cube':
        properties['size'] = 1.0 + _random.nextDouble() * 1.5;
        properties['color'] = Colors.blue.toARGB32();
        properties['canStealMass'] = difficulty > 5;
        break;
        
      case 'balloon':
        properties['radius'] = 1.5 + _random.nextDouble() * 0.5;
        properties['liftForce'] = 10.0 + _random.nextDouble() * 10.0;
        break;
        
      case 'magnet':
        properties['radius'] = 1.3;
        properties['magnetStrength'] = 50.0 + _random.nextDouble() * 100.0;
        properties['polarity'] = _random.nextBool() ? 1 : -1;
        break;
        
      case 'energy_sphere':
        properties['radius'] = 1.5;
        properties['maxCharge'] = 100.0;
        properties['chargeRate'] = 10.0 + _random.nextDouble() * 20.0;
        break;
        
      case 'portal':
        properties['radius'] = 2.0;
        properties['targetPosition'] = {
          'x': (_random.nextDouble() - 0.5) * 10,
          'y': (_random.nextDouble() - 0.5) * 8,
        };
        break;
        
      case 'time_crystal':
        properties['radius'] = 1.2;
        properties['timeScale'] = 0.1 + _random.nextDouble() * 0.4;
        properties['fieldRadius'] = 3.0 + _random.nextDouble() * 2.0;
        break;
    }
    
    return properties;
  }
  
  List<CustomGravityField> _generateGravityFields(int difficulty) {
    final fields = <CustomGravityField>[];
    final fieldCount = (difficulty / 3).round().clamp(1, 3);
    
    for (int i = 0; i < fieldCount; i++) {
      fields.add(CustomGravityField(
        center: Vector2(
          (_random.nextDouble() - 0.5) * 15,
          (_random.nextDouble() - 0.5) * 10,
        ),
        radius: 3.0 + _random.nextDouble() * 3.0,
        gravity: Vector2(
          (_random.nextDouble() - 0.5) * 20,
          (_random.nextDouble() - 0.5) * 20,
        ),
        strength: 0.5 + _random.nextDouble() * 0.5,
      ));
    }
    
    return fields;
  }
  
  List<Obstacle> _generateObstacles(int difficulty) {
    final obstacles = <Obstacle>[];
    final obstacleCount = (difficulty / 2).round();
    
    for (int i = 0; i < obstacleCount; i++) {
      obstacles.add(Obstacle(
        type: _random.nextBool() ? 'wall' : 'moving_platform',
        position: Vector2(
          (_random.nextDouble() - 0.5) * 15,
          (_random.nextDouble() - 0.5) * 10,
        ),
        size: Vector2(
          1.0 + _random.nextDouble() * 3.0,
          0.5 + _random.nextDouble() * 1.0,
        ),
        properties: {
          'material': _random.nextBool() ? 'metal' : 'rubber',
          'isDestructible': difficulty > 6 && _random.nextBool(),
        },
      ));
    }
    
    return obstacles;
  }
  
  List<Map<String, dynamic>> _generateDecorations(int difficulty) {
    // Visual elements that don't affect gameplay
    return List.generate(difficulty * 2, (index) => {
      'type': 'particle_emitter',
      'position': {
        'x': (_random.nextDouble() - 0.5) * 20,
        'y': (_random.nextDouble() - 0.5) * 15,
      },
      'color': Colors.primaries[_random.nextInt(Colors.primaries.length)].toARGB32(),
      'particleCount': 10 + _random.nextInt(20),
    });
  }
  
  List<Map<String, dynamic>> _generateParticleEffects(int difficulty) {
    return [
      {
        'type': 'quantum_field',
        'intensity': 0.5 + (difficulty / 20),
        'color': Colors.cyan.toARGB32(),
      },
      if (difficulty > 5) {
        'type': 'space_distortion',
        'strength': difficulty / 10,
      },
    ];
  }
  
  StarThresholds _calculateStarThresholds(int difficulty) {
    final baseTime = 30.0 + (difficulty * 15.0);
    
    return StarThresholds(
      oneStar: ThresholdRequirement(
        timeLimit: baseTime * 2,
        minScore: 1000,
      ),
      twoStars: ThresholdRequirement(
        timeLimit: baseTime * 1.5,
        minScore: 2000,
        bonusObjective: 'Collect 50% of bonus items',
      ),
      threeStars: ThresholdRequirement(
        timeLimit: baseTime,
        minScore: 3000,
        bonusObjective: 'Perfect run - no retries',
        specialRequirement: 'Use less than 3 gravity changes',
      ),
    );
  }
  
  List<String> _generateHints(List<LevelObject> objects, List<VictoryCondition> goals) {
    final hints = <String>[];
    
    // Analyze level for hint generation
    if (objects.any((obj) => obj.type == 'magnet')) {
      hints.add('Magnets can attract or repel other magnetic objects');
    }
    
    if (objects.any((obj) => obj.type == 'portal')) {
      hints.add('Portals instantly transport objects to new locations');
    }
    
    if (objects.any((obj) => obj.type == 'time_crystal')) {
      hints.add('Time crystals slow down time in their vicinity');
    }
    
    // Goal-specific hints
    if (goals.any((goal) => goal is TimeCondition)) {
      hints.add('Speed is key! Find the fastest route to victory');
    }
    
    return hints;
  }
  
  List<String> _generateTutorial(List<LevelObject> objects, List<VictoryCondition> goals) {
    return [
      'Tap and drag to change gravity direction',
      'Guide the green ball to the target',
      if (objects.length > 3) 'Use other objects to help reach your goal',
      'Earn stars by completing the level quickly',
    ];
  }
  
  String _generateLevelName(String prompt) {
    // In production, this would use GPT-4 to generate creative names
    final adjectives = ['Quantum', 'Twisted', 'Gravitational', 'Paradoxical', 'Ethereal'];
    final nouns = ['Puzzle', 'Challenge', 'Conundrum', 'Enigma', 'Maze'];
    
    return '${adjectives[_random.nextInt(adjectives.length)]} ${nouns[_random.nextInt(nouns.length)]}';
  }
  
  String _generateDescription(String prompt, int difficulty) {
    final descriptions = [
      'A mind-bending physics puzzle that defies expectations',
      'Navigate through quantum uncertainties to reach your goal',
      'Master gravity to overcome this challenging obstacle course',
      'Use creative thinking to solve this paradoxical puzzle',
    ];
    
    return descriptions[_random.nextInt(descriptions.length)];
  }
  
  String _generateLevelPrompt({
    required String worldTheme,
    required int levelNumber,
    required bool isSpecial,
  }) {
    if (isSpecial) {
      return 'Create a boss level or special challenge for $worldTheme world, level $levelNumber. Make it memorable and unique!';
    }
    
    return 'Design level $levelNumber for $worldTheme world. It should teach or test a specific physics concept while being fun.';
  }
  
  SketchAnalysis _analyzeSketch(List<SketchElement> sketch) {
    // Analyze drawn elements to understand player intent
    final objects = sketch.where((e) => e.type == 'object').toList();
    final paths = sketch.where((e) => e.type == 'path').toList();
    final annotations = sketch.where((e) => e.type == 'annotation').toList();
    
    final mechanics = <String>[];
    if (paths.any((p) => p.properties['curved'] == true)) {
      mechanics.add('curved trajectory');
    }
    if (objects.any((o) => o.properties['rotating'] == true)) {
      mechanics.add('rotation');
    }
    if (annotations.any((a) => a.text?.contains('portal') ?? false)) {
      mechanics.add('teleportation');
    }
    
    return SketchAnalysis(
      objectCount: objects.length,
      mechanics: mechanics,
      estimatedDifficulty: (objects.length * 2).clamp(1, 10),
      detectedElements: objects.map((o) => o.properties['type'] as String).toList(),
    );
  }
  
  String _getWorldName(int worldId) {
    const worldNames = {
      1: "Newton's Laboratory",
      2: 'Zero-G Space Station',
      3: 'Quantum Realm',
      4: 'Time Distortion Zone',
      5: 'Magnetic Metropolis',
      6: 'The Singularity',
    };
    return worldNames[worldId] ?? 'Unknown World';
  }
  
  Vector2 _getWorldBaseGravity(int worldId) {
    switch (worldId) {
      case 1: return Vector2(0, 9.81); // Earth gravity
      case 2: return Vector2(0, 0); // Zero gravity
      case 3: return Vector2(0, 4.9); // Half gravity
      case 4: return Vector2(0, 9.81); // Normal but time-affected
      case 5: return Vector2(0, 9.81); // Normal but magnetic
      case 6: return Vector2(0, 15); // Heavy gravity
      default: return Vector2(0, 9.81);
    }
  }
  
  List<EnvironmentEffect> _getWorldEnvironmentEffects(int worldId) {
    switch (worldId) {
      case 2: // Space station
        return [
          EnvironmentEffect(type: 'asteroids', frequency: 0.1),
          EnvironmentEffect(type: 'solar_wind', strength: 0.3),
        ];
      case 3: // Quantum realm
        return [
          EnvironmentEffect(type: 'probability_waves', intensity: 0.5),
          EnvironmentEffect(type: 'quantum_tunneling', chance: 0.05),
        ];
      case 4: // Time zone
        return [
          EnvironmentEffect(type: 'time_rifts', density: 0.2),
          EnvironmentEffect(type: 'temporal_echoes', count: 3),
        ];
      default:
        return [];
    }
  }
  
  LevelDifficulty _difficultyToEnum(int difficulty) {
    if (difficulty <= 2) return LevelDifficulty.tutorial;
    if (difficulty <= 4) return LevelDifficulty.easy;
    if (difficulty <= 6) return LevelDifficulty.medium;
    if (difficulty <= 8) return LevelDifficulty.hard;
    if (difficulty <= 9) return LevelDifficulty.expert;
    return LevelDifficulty.insane;
  }
  
  List<GameObjectSpawn> _convertToGameObjectSpawns(List<LevelObject> objects) {
    return objects.map((obj) => GameObjectSpawn(
      objectType: obj.type,
      position: obj.position,
      properties: obj.properties,
    )).toList();
  }
  
  VisualTheme _generateVisualTheme(int worldId) {
    switch (worldId) {
      case 1:
        return VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.blue, Colors.green, Colors.white],
          particleTheme: 'scientific',
          ambientIntensity: 0.8,
        );
      case 2:
        return VisualTheme(
          backgroundType: 'space',
          colorPalette: [Colors.deepPurple, Colors.black, Colors.blue],
          particleTheme: 'stars',
          ambientIntensity: 0.6,
        );
      case 3:
        return VisualTheme(
          backgroundType: 'quantum',
          colorPalette: [Colors.cyan, Colors.purple, Colors.pink],
          particleTheme: 'quantum_waves',
          ambientIntensity: 1.2,
        );
      default:
        return VisualTheme(
          backgroundType: 'abstract',
          colorPalette: [Colors.grey, Colors.blue, Colors.white],
          particleTheme: 'default',
          ambientIntensity: 1.0,
        );
    }
  }
}

/// Sketch element for level creation from drawings
class SketchElement {
  final String type; // 'object', 'path', 'annotation'
  final List<Vector2> points;
  final Map<String, dynamic> properties;
  final String? text;
  
  SketchElement({
    required this.type,
    required this.points,
    this.properties = const {},
    this.text,
  });
}

/// Analysis result from sketch
class SketchAnalysis {
  final int objectCount;
  final List<String> mechanics;
  final int estimatedDifficulty;
  final List<String> detectedElements;
  
  SketchAnalysis({
    required this.objectCount,
    required this.mechanics,
    required this.estimatedDifficulty,
    required this.detectedElements,
  });
}

/// Custom gravity field configuration
class CustomGravityField {
  final Vector2 center;
  final double radius;
  final Vector2 gravity;
  final double strength;
  
  CustomGravityField({
    required this.center,
    required this.radius,
    required this.gravity,
    required this.strength,
  });
}

/// Level obstacle
class Obstacle {
  final String type;
  final Vector2 position;
  final Vector2 size;
  final Map<String, dynamic> properties;
  
  Obstacle({
    required this.type,
    required this.position,
    required this.size,
    this.properties = const {},
  });
}

/// Environment effect
class EnvironmentEffect {
  final String type;
  final double? frequency;
  final double? strength;
  final double? intensity;
  final double? chance;
  final double? density;
  final int? count;
  
  EnvironmentEffect({
    required this.type,
    this.frequency,
    this.strength,
    this.intensity,
    this.chance,
    this.density,
    this.count,
  });
}

/// Level object definition
class LevelObject {
  final String id;
  final String type;
  final Vector2 position;
  final Map<String, dynamic> properties;
  
  LevelObject({
    required this.id,
    required this.type,
    required this.position,
    required this.properties,
  });
}

/// Star threshold requirements
// StarThresholds and ThresholdRequirement are defined in level.dart
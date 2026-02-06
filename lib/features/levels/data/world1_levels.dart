import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../domain/entities/level.dart';
import '../domain/entities/victory_conditions.dart';

/// World 1: Newton's Lab - Tutorial and Basic Mechanics
class World1Levels {
  static List<Level> getLevels() {
    return [
      // Level 1-1: First Steps (Tutorial)
      Level(
        id: 'world1_level1',
        name: 'First Steps',
        description: 'Learn to switch gravity',
        worldId: 1,
        levelNumber: 1,
        difficulty: LevelDifficulty.tutorial,
        objects: [
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(100, 100),
            properties: {'radius': 15.0, 'color': '#FF0000', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(300, 500),
            properties: {'width': 60.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
          bounciness: 0.5,
          friction: 0.3,
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.blue, Colors.cyan, Colors.white],
        ),
        perfectMoves: 1,
        perfectTime: 5.0,
        hints: ['Tap below the ball to make it fall down'],
        tutorialSteps: ['intro', 'gravity_switch', 'goal_reach'],
      ),
      
      // Level 1-2: Two Balls (Tutorial)
      Level(
        id: 'world1_level2',
        name: 'Double Trouble',
        description: 'Control multiple objects',
        worldId: 1,
        levelNumber: 2,
        difficulty: LevelDifficulty.tutorial,
        objects: [
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(100, 100),
            properties: {'radius': 15.0, 'color': '#FF0000', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(300, 100),
            properties: {'radius': 15.0, 'color': '#00FF00', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(200, 500),
            properties: {'width': 100.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.blue, Colors.cyan, Colors.white],
        ),
        perfectMoves: 2,
        perfectTime: 8.0,
      ),
      
      // Level 1-3: Obstacles Introduction
      Level(
        id: 'world1_level3',
        name: 'Blocked Path',
        description: 'Navigate around obstacles',
        worldId: 1,
        levelNumber: 3,
        difficulty: LevelDifficulty.tutorial,
        objects: [
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(100, 100),
            properties: {'radius': 15.0, 'color': '#FF0000', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(200, 300),
            properties: {'width': 200.0, 'height': 20.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(300, 500),
            properties: {'width': 60.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.blue, Colors.cyan, Colors.white],
        ),
        perfectMoves: 3,
        perfectTime: 10.0,
      ),
      
      // Level 1-4: Diagonal Gravity
      Level(
        id: 'world1_level4',
        name: 'Think Sideways',
        description: 'Master diagonal gravity',
        worldId: 1,
        levelNumber: 4,
        difficulty: LevelDifficulty.tutorial,
        objects: [
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(50, 300),
            properties: {'radius': 15.0, 'color': '#FF0000', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(200, 200),
            rotation: 0.785, // 45 degrees
            properties: {'width': 150.0, 'height': 20.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(350, 100),
            properties: {'width': 60.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.blue, Colors.cyan, Colors.white],
        ),
        perfectMoves: 2,
        perfectTime: 8.0,
        hints: ['Try using diagonal gravity!'],
      ),
      
      // Level 1-5: Boss - Complete Control
      Level(
        id: 'world1_level5',
        name: 'Final Exam',
        description: 'Show what you\'ve learned',
        worldId: 1,
        levelNumber: 5,
        difficulty: LevelDifficulty.easy,
        objects: [
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(50, 100),
            properties: {'radius': 15.0, 'color': '#FF0000', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(350, 100),
            properties: {'radius': 15.0, 'color': '#00FF00', 'mass': 1.5},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(200, 250),
            properties: {'width': 300.0, 'height': 20.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(100, 400),
            properties: {'width': 20.0, 'height': 100.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(300, 400),
            properties: {'width': 20.0, 'height': 100.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(200, 500),
            properties: {'width': 80.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.purple, Colors.blue, Colors.cyan],
          specialEffects: ['particle_trail'],
        ),
        perfectMoves: 5,
        perfectTime: 15.0,
      ),
      
      // Level 1-6: Momentum Matters
      Level(
        id: 'world1_level6',
        name: 'Momentum Matters',
        description: 'Use physics to your advantage',
        worldId: 1,
        levelNumber: 6,
        difficulty: LevelDifficulty.easy,
        objects: [
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(50, 100),
            properties: {'radius': 20.0, 'color': '#FF0000', 'mass': 2.0},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(200, 300),
            rotation: -0.3,
            properties: {'width': 200.0, 'height': 20.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(350, 500),
            properties: {'width': 60.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
          bounciness: 0.7,
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.blue, Colors.cyan, Colors.white],
        ),
        perfectMoves: 3,
        perfectTime: 10.0,
      ),
      
      // Levels 7-20 continue with increasing complexity...
      // I'll generate a few more representative levels
      
      // Level 1-10: The Maze
      Level(
        id: 'world1_level10',
        name: 'The Maze',
        description: 'Navigate the labyrinth',
        worldId: 1,
        levelNumber: 10,
        difficulty: LevelDifficulty.medium,
        objects: [
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(50, 50),
            properties: {'radius': 12.0, 'color': '#FF0000', 'mass': 1.0},
          ),
          // Maze walls
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(150, 100),
            properties: {'width': 200.0, 'height': 20.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(250, 200),
            properties: {'width': 200.0, 'height': 20.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(150, 300),
            properties: {'width': 200.0, 'height': 20.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(100, 200),
            properties: {'width': 20.0, 'height': 200.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(300, 250),
            properties: {'width': 20.0, 'height': 200.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(350, 550),
            properties: {'width': 60.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.blue, Colors.cyan, Colors.white],
        ),
        perfectMoves: 8,
        perfectTime: 20.0,
      ),
      
      // Level 1-15: Chain Reaction
      Level(
        id: 'world1_level15',
        name: 'Chain Reaction',
        description: 'Set up the perfect sequence',
        worldId: 1,
        levelNumber: 15,
        difficulty: LevelDifficulty.medium,
        objects: [
          // Multiple balls that need to interact
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(50, 50),
            properties: {'radius': 15.0, 'color': '#FF0000', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(200, 200),
            properties: {'radius': 20.0, 'color': '#00FF00', 'mass': 2.0},
          ),
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(350, 50),
            properties: {'radius': 15.0, 'color': '#0000FF', 'mass': 1.0},
          ),
          // Dynamic obstacle
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(200, 350),
            properties: {'width': 150.0, 'height': 20.0, 'static': false},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(200, 550),
            properties: {'width': 150.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
          bounciness: 0.6,
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory',
          colorPalette: [Colors.blue, Colors.cyan, Colors.white],
        ),
        perfectMoves: 6,
        perfectTime: 18.0,
      ),
      
      // Level 1-20: Boss - Newton's Challenge
      Level(
        id: 'world1_level20',
        name: 'Newton\'s Challenge',
        description: 'Master of gravity awaits',
        worldId: 1,
        levelNumber: 20,
        difficulty: LevelDifficulty.hard,
        objects: [
          // Complex setup with multiple solutions
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(50, 50),
            properties: {'radius': 15.0, 'color': '#FF0000', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(350, 50),
            properties: {'radius': 15.0, 'color': '#00FF00', 'mass': 1.0},
          ),
          GameObjectSpawn(
            objectType: 'ball',
            position: Vector2(200, 100),
            properties: {'radius': 20.0, 'color': '#FFFF00', 'mass': 3.0},
          ),
          // Moving platforms
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(100, 250),
            rotation: 0.2,
            properties: {'width': 100.0, 'height': 20.0, 'static': false},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(300, 250),
            rotation: -0.2,
            properties: {'width': 100.0, 'height': 20.0, 'static': false},
          ),
          // Static maze
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(200, 400),
            properties: {'width': 300.0, 'height': 20.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(50, 450),
            properties: {'width': 20.0, 'height': 100.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'obstacle',
            position: Vector2(350, 450),
            properties: {'width': 20.0, 'height': 100.0, 'static': true},
          ),
          GameObjectSpawn(
            objectType: 'goal',
            position: Vector2(200, 550),
            properties: {'width': 100.0, 'height': 60.0},
          ),
        ],
        victoryConditions: [
          AllBallsInGoalCondition(),
          TimeCondition(maxTime: 30.0),
        ],
        physicsConfig: PhysicsConfig(
          gravity: Vector2(0, 98),
          bounciness: 0.5,
          friction: 0.4,
        ),
        visualTheme: VisualTheme(
          backgroundType: 'laboratory_boss',
          colorPalette: [Colors.purple, Colors.pink, Colors.orange],
          specialEffects: ['particle_trail', 'glow', 'lightning'],
        ),
        perfectMoves: 10,
        perfectTime: 25.0,
        starThresholds: StarThresholds(
          oneStar: ThresholdRequirement(timeLimit: 30.0, minScore: 1000),
          twoStars: ThresholdRequirement(timeLimit: 25.0, minScore: 2000),
          threeStars: ThresholdRequirement(timeLimit: 20.0, minScore: 3000),
        ),
      ),
    ];
  }
  
  /// Generate remaining levels procedurally
  static List<Level> generateRemainingLevels() {
    final levels = <Level>[];
    
    // Levels 7-9: Easy progression
    for (int i = 7; i <= 9; i++) {
      levels.add(_generateLevel(
        levelNumber: i,
        difficulty: LevelDifficulty.easy,
        ballCount: 1 + (i ~/ 3),
        obstacleCount: 2 + (i ~/ 4),
      ));
    }
    
    // Levels 11-14: Medium difficulty
    for (int i = 11; i <= 14; i++) {
      levels.add(_generateLevel(
        levelNumber: i,
        difficulty: LevelDifficulty.medium,
        ballCount: 2 + (i ~/ 5),
        obstacleCount: 3 + (i ~/ 4),
      ));
    }
    
    // Levels 16-19: Hard progression
    for (int i = 16; i <= 19; i++) {
      levels.add(_generateLevel(
        levelNumber: i,
        difficulty: LevelDifficulty.hard,
        ballCount: 2 + (i ~/ 6),
        obstacleCount: 4 + (i ~/ 5),
      ));
    }
    
    return levels;
  }
  
  static Level _generateLevel({
    required int levelNumber,
    required LevelDifficulty difficulty,
    required int ballCount,
    required int obstacleCount,
  }) {
    final objects = <GameObjectSpawn>[];
    
    // Add balls
    for (int i = 0; i < ballCount; i++) {
      objects.add(GameObjectSpawn(
        objectType: 'ball',
        position: Vector2(
          50 + i * 100.0,
          50 + i * 50.0,
        ),
        properties: {
          'radius': 15.0,
          'color': ['#FF0000', '#00FF00', '#0000FF'][i % 3],
          'mass': 1.0 + i * 0.5,
        },
      ));
    }
    
    // Add obstacles
    for (int i = 0; i < obstacleCount; i++) {
      objects.add(GameObjectSpawn(
        objectType: 'obstacle',
        position: Vector2(
          100 + i * 60.0,
          200 + i * 80.0,
        ),
        rotation: i * 0.2,
        properties: {
          'width': 80.0 + i * 20.0,
          'height': 20.0,
          'static': i % 2 == 0,
        },
      ));
    }
    
    // Add goal
    objects.add(GameObjectSpawn(
      objectType: 'goal',
      position: Vector2(200, 500),
      properties: {
        'width': 80.0 + ballCount * 10.0,
        'height': 60.0,
      },
    ));
    
    return Level(
      id: 'world1_level$levelNumber',
      name: 'Level 1-$levelNumber',
      description: 'Challenge your skills',
      worldId: 1,
      levelNumber: levelNumber,
      difficulty: difficulty,
      objects: objects,
      victoryConditions: [AllBallsInGoalCondition()],
      physicsConfig: PhysicsConfig(
        gravity: Vector2(0, 98),
        bounciness: 0.5 + levelNumber * 0.01,
        friction: 0.3 - levelNumber * 0.005,
      ),
      visualTheme: VisualTheme(
        backgroundType: 'laboratory',
        colorPalette: [Colors.blue, Colors.cyan, Colors.white],
      ),
      perfectMoves: 3 + levelNumber ~/ 2,
      perfectTime: 10.0 + levelNumber * 0.5,
    );
  }
}
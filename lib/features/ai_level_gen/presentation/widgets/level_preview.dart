import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../../levels/domain/entities/level.dart';
import '../../../game/domain/entities/quantum_game_object.dart';
import '../../../levels/domain/entities/victory_conditions.dart';

/// Real-time preview of generated level
class LevelPreview extends StatefulWidget {
  final Level level;
  final Function(dynamic) onEdit;
  
  const LevelPreview({
    super.key,
    required this.level,
    required this.onEdit,
  });

  @override
  State<LevelPreview> createState() => _LevelPreviewState();
}

class _LevelPreviewState extends State<LevelPreview> {
  late LevelPreviewGame _game;
  
  @override
  void initState() {
    super.initState();
    _game = LevelPreviewGame(level: widget.level);
  }
  
  @override
  void didUpdateWidget(LevelPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _game.updateLevel(widget.level);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Game view
        GameWidget(game: _game),
        
        // Overlay info
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildLevelInfo(),
        ),
        
        // Edit controls
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildEditControls(),
        ),
      ],
    );
  }
  
  Widget _buildLevelInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.level.name,
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Difficulty indicator
              ...List.generate(
                _difficultyToStars(widget.level.difficulty),
                (index) => const Icon(Icons.star, color: Colors.yellow, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.level.description,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Victory conditions
          Text(
            'OBJECTIVES:',
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          ...widget.level.victoryConditions.map((condition) => Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    condition.description,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildEditControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Test Play',
            color: Colors.green,
            onTap: _testPlay,
          ),
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reset',
            color: Colors.orange,
            onTap: _resetLevel,
          ),
          _buildControlButton(
            icon: Icons.settings,
            label: 'Physics',
            color: Colors.blue,
            onTap: _editPhysics,
          ),
          _buildControlButton(
            icon: Icons.palette,
            label: 'Theme',
            color: Colors.purple,
            onTap: _editTheme,
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
  
  int _difficultyToStars(LevelDifficulty difficulty) {
    switch (difficulty) {
      case LevelDifficulty.tutorial: return 1;
      case LevelDifficulty.easy: return 1;
      case LevelDifficulty.medium: return 2;
      case LevelDifficulty.hard: return 3;
      case LevelDifficulty.expert: return 4;
      case LevelDifficulty.insane: return 5;
    }
  }
  
  void _testPlay() {
    _game.startTestPlay();
  }
  
  void _resetLevel() {
    _game.resetLevel();
  }
  
  void _editPhysics() {
    widget.onEdit(widget.level.physicsConfig);
  }
  
  void _editTheme() {
    widget.onEdit(widget.level.visualTheme);
  }
}

/// Preview game engine
class LevelPreviewGame extends Forge2DGame {
  final Level level;
  final List<QuantumGameObject> objects = [];
  bool isTestMode = false;
  
  LevelPreviewGame({required this.level}) : super(
    gravity: level.physicsConfig.gravity,
  );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Set up camera
    camera.viewfinder.visibleGameSize = Vector2(20, 15);
    
    // Create level boundaries
    _createBoundaries();
    
    // Spawn objects
    _spawnObjects();
    
    // Add visual elements
    _addVisualElements();
  }
  
  void _createBoundaries() {
    final boundaries = [
      // Top
      _createWall(Vector2(0, -8), Vector2(20, 0.5)),
      // Bottom
      _createWall(Vector2(0, 8), Vector2(20, 0.5)),
      // Left
      _createWall(Vector2(-10.5, 0), Vector2(0.5, 15)),
      // Right
      _createWall(Vector2(10.5, 0), Vector2(0.5, 15)),
    ];
    
    for (final wall in boundaries) {
      add(wall);
    }
  }
  
  BodyComponent _createWall(Vector2 position, Vector2 size) {
    return BodyComponent(
      bodyDef: BodyDef()
        ..type = BodyType.static
        ..position = position,
      fixtureDefs: [
        FixtureDef(
          PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2),
        )
          ..friction = 0.5
          ..restitution = 0.3,
      ],
    );
  }
  
  void _spawnObjects() {
    for (final spawn in level.objects) {
      try {
        final object = spawn.createObject();
        add(object);
        objects.add(object);
      } catch (e) {
        // Error spawning object: $e
      }
    }
  }
  
  void _addVisualElements() {
    // Add goal indicators
    for (final condition in level.victoryConditions) {
      if (condition.type == 'reach_goal' && condition.parameters['goalPosition'] != null) {
        final pos = condition.parameters['goalPosition'] as Vector2;
        final rad = condition.parameters['goalRadius'] as double? ?? 2.0;
        add(GoalIndicator(
          position: pos,
          radius: rad,
        ));
      }
    }
  }
  
  void updateLevel(Level newLevel) {
    // Clear existing objects
    for (final obj in objects) {
      remove(obj);
    }
    objects.clear();
    
    // Update physics
    world.gravity = newLevel.physicsConfig.gravity;
    
    // Spawn new objects
    _spawnObjects();
  }
  
  void startTestPlay() {
    isTestMode = true;
    // Enable player controls
  }
  
  void resetLevel() {
    updateLevel(level);
    isTestMode = false;
  }
}

/// Goal indicator component
class GoalIndicator extends PositionComponent {
  final double radius;
  
  GoalIndicator({
    required super.position,
    required this.radius,
  });
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Animated rings
    for (int i = 0; i < 3; i++) {
      paint.color = Colors.green.withValues(
        alpha: 0.3 - i * 0.1,
      );
      canvas.drawCircle(
        Offset.zero,
        radius + i * 10,
        paint,
      );
    }
    
    // Center point
    paint.style = PaintingStyle.fill;
    paint.color = Colors.green;
    canvas.drawCircle(Offset.zero, 3, paint);
  }
}
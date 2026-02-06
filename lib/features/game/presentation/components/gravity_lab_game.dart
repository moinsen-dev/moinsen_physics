import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../../../levels/domain/entities/level.dart';
import '../../../game/domain/entities/quantum_game_object.dart';
import '../../domain/use_cases/game_state_manager.dart';
import 'physics_objects/ball_object.dart';
import 'physics_objects/obstacle_object.dart';
import 'physics_objects/goal_object.dart';
import 'physics_objects/gravity_controller.dart';

/// Main game engine for Gravity Lab
class GravityLabGame extends Forge2DGame
    with TapCallbacks, DragCallbacks, HasCollisionDetection {
  final Level level;
  final Function(int stars, int moves, double time) onVictory;
  final VoidCallback onFailure;
  final VoidCallback onMove;
  final Function(double time) onTimeUpdate;
  final Function(Vector2 position, double force) onCollision;
  final Function(Vector2 position, Vector2 oldGravity, Vector2 newGravity) onGravitySwitch;
  
  // Game state
  late GravityController gravityController;
  late GameStateManager stateManager;
  final List<BallObject> balls = [];
  final List<ObstacleObject> obstacles = [];
  final List<GoalObject> goals = [];
  
  bool _inputEnabled = true;
  bool _isPaused = false;
  int _moves = 0;
  double _timeElapsed = 0;
  // double _bestTime = double.infinity; // Reserved for future use
  int _ballsInGoal = 0;
  bool _isUndoingOrRedoing = false;
  
  // Victory conditions
  late final VictoryCondition victoryCondition;
  
  GravityLabGame({
    required this.level,
    required this.onVictory,
    required this.onFailure,
    required this.onMove,
    required this.onTimeUpdate,
    required this.onCollision,
    required this.onGravitySwitch,
  }) : super(
    gravity: Vector2(0, 98), // Default gravity (10x for visible effect)
    camera: CameraComponent.withFixedResolution(
      width: 400,
      height: 600,
    ),
  );
  
  @override
  Color backgroundColor() => Colors.black;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize gravity controller
    gravityController = GravityController(
      initialGravity: world.gravity,
      onGravityChange: _handleGravityChange,
    );
    world.add(gravityController);
    
    // Initialize state manager
    stateManager = GameStateManager();
    
    // Load level
    await _loadLevel();
    
    // Set up victory condition
    victoryCondition = level.victoryCondition;
    
    // Add boundaries
    _addBoundaries();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_isPaused) {
      _timeElapsed += dt;
      onTimeUpdate(_timeElapsed);
      
      // Check victory conditions
      if (_checkVictoryCondition()) {
        _onLevelComplete();
      }
      
      // Check failure conditions
      if (_checkFailureCondition()) {
        onFailure();
        pauseEngine();
      }
    }
  }
  
  Future<void> _loadLevel() async {
    // Clear existing objects
    balls.clear();
    obstacles.clear();
    goals.clear();
    _ballsInGoal = 0;
    
    // Create physics objects from level data
    for (final obj in level.objects) {
      switch (obj.type) {
        case 'ball':
          final ball = BallObject(
            position: obj.position,
            radius: obj.size.x / 2,
            color: _parseColor(obj.properties['color'] ?? '#FF0000'),
            mass: obj.properties['mass']?.toDouble() ?? 1.0,
            onCollision: (force) => onCollision(obj.position, force),
          );
          balls.add(ball);
          world.add(ball);
          break;
          
        case 'obstacle':
          final obstacle = ObstacleObject(
            position: obj.position,
            size: obj.size,
            angle: obj.angle,
            color: _parseColor(obj.properties['color'] ?? '#808080'),
            isStatic: obj.properties['static'] ?? true,
          );
          obstacles.add(obstacle);
          world.add(obstacle);
          break;
          
        case 'goal':
          final goal = GoalObject(
            position: obj.position,
            size: obj.size,
            onBallEnter: _onBallEnterGoal,
            onBallExit: _onBallExitGoal,
          );
          goals.add(goal);
          world.add(goal);
          break;
      }
    }
  }
  
  void _addBoundaries() {
    final boundaries = [
      // Top
      ObstacleObject(
        position: Vector2(200, -10),
        size: Vector2(400, 20),
        angle: 0,
        color: Colors.grey,
        isStatic: true,
      ),
      // Bottom
      ObstacleObject(
        position: Vector2(200, 610),
        size: Vector2(400, 20),
        angle: 0,
        color: Colors.grey,
        isStatic: true,
      ),
      // Left
      ObstacleObject(
        position: Vector2(-10, 300),
        size: Vector2(20, 600),
        angle: 0,
        color: Colors.grey,
        isStatic: true,
      ),
      // Right
      ObstacleObject(
        position: Vector2(410, 300),
        size: Vector2(20, 600),
        angle: 0,
        color: Colors.grey,
        isStatic: true,
      ),
    ];
    
    for (final boundary in boundaries) {
      world.add(boundary);
    }
  }
  
  void _handleGravityChange(Vector2 oldGravity, Vector2 newGravity) {
    if (!_isUndoingOrRedoing) {
      // Save state before change
      _saveGameState();
    }
    
    world.gravity = newGravity;
    _moves++;
    onMove();
    onGravitySwitch(size / 2, oldGravity, newGravity);
  }
  
  void _onBallEnterGoal(BallObject ball) {
    _ballsInGoal++;
  }
  
  void _onBallExitGoal(BallObject ball) {
    _ballsInGoal--;
  }
  
  bool _checkVictoryCondition() {
    final gameState = SimpleGameState(
      ballsInGoal: _ballsInGoal,
      totalBalls: balls.length,
      elapsedTime: _timeElapsed,
      moves: _moves,
      ballPositions: balls.map((b) => b.body.position).toList(),
      goalPositions: goals.map((g) => g.position).toList(),
    );
    
    return victoryCondition.isMet(gameState);
  }
  
  bool _checkFailureCondition() {
    // Check if all balls are stuck or fallen off screen
    for (final ball in balls) {
      final pos = ball.body.position;
      if (pos.y > 0 && pos.y < 600 && pos.x > 0 && pos.x < 400) {
        // At least one ball is still in play
        return false;
      }
    }
    return true;
  }
  
  void _onLevelComplete() {
    pauseEngine();
    
    // Calculate stars based on performance
    int stars = 3;
    
    // Deduct stars for excess moves
    if (_moves > level.perfectMoves * 1.5) {
      stars--;
    }
    if (_moves > level.perfectMoves * 2) {
      stars--;
    }
    
    // Deduct stars for excess time
    if (_timeElapsed > level.perfectTime * 1.5) {
      stars--;
    }
    if (_timeElapsed > level.perfectTime * 2) {
      stars--;
    }
    
    stars = stars.clamp(1, 3);
    
    onVictory(stars, _moves, _timeElapsed);
  }
  
  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  }
  
  // Input handling
  @override
  void onTapUp(TapUpEvent event) {
    if (!_inputEnabled || _isPaused) return;
    
    final tapPosition = event.localPosition;
    gravityController.handleTap(tapPosition);
  }
  
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_inputEnabled || _isPaused) return;
    
    gravityController.handleDrag(event.localDelta);
  }
  
  // Control methods
  void enableInput() => _inputEnabled = true;
  void disableInput() => _inputEnabled = false;
  
  @override
  void pauseEngine() {
    _isPaused = true;
    super.pauseEngine();
  }
  
  @override
  void resumeEngine() {
    _isPaused = false;
    super.resumeEngine();
  }
  
  void resetLevel() {
    _moves = 0;
    _timeElapsed = 0;
    _ballsInGoal = 0;
    _isPaused = false;
    
    // Remove all game objects
    world.removeAll(balls);
    world.removeAll(obstacles);
    world.removeAll(goals);
    
    // Reload level
    _loadLevel();
    
    // Reset gravity
    gravityController.reset();
    world.gravity = gravityController.currentGravity;
    
    // Clear undo/redo history
    stateManager.clear();
  }
  
  // Undo/Redo functionality
  void _saveGameState() {
    final snapshot = GameStateSnapshot.fromGame(
      gravity: world.gravity,
      balls: balls,
      obstacles: obstacles,
      goals: goals,
      moves: _moves,
      timeElapsed: _timeElapsed,
    );
    
    stateManager.saveState(snapshot);
  }
  
  bool get canUndo => stateManager.canUndo;
  bool get canRedo => stateManager.canRedo;
  
  void undo() {
    final state = stateManager.undo();
    if (state != null) {
      _isUndoingOrRedoing = true;
      _applyGameState(state);
      _isUndoingOrRedoing = false;
    }
  }
  
  void redo() {
    final state = stateManager.redo();
    if (state != null) {
      _isUndoingOrRedoing = true;
      _applyGameState(state);
      _isUndoingOrRedoing = false;
    }
  }
  
  void _applyGameState(GameStateSnapshot state) {
    // Apply gravity
    world.gravity = state.gravity;
    gravityController.currentGravity = state.gravity;
    
    // Apply ball states
    for (int i = 0; i < balls.length && i < state.balls.length; i++) {
      state.balls[i].applyTo(balls[i]);
    }
    
    // Apply obstacle states
    for (int i = 0; i < obstacles.length && i < state.obstacles.length; i++) {
      state.obstacles[i].applyTo(obstacles[i]);
    }
    
    // Restore game stats
    _moves = state.moves;
    _timeElapsed = state.timeElapsed;
    
    // Notify UI
    onMove();
    onTimeUpdate(_timeElapsed);
  }
}

/// Game state for victory condition checking
class SimpleGameState implements GameState {
  final int ballsInGoal;
  final int totalBalls;
  @override
  final double elapsedTime;
  final int moves;
  final List<Vector2> ballPositions;
  final List<Vector2> goalPositions;
  
  @override
  final List<QuantumGameObject> objects = [];
  @override
  final int collectiblesCollected = 0;
  @override
  final bool playerAlive = true;
  @override
  final Map<String, dynamic> customState = {};
  
  SimpleGameState({
    required this.ballsInGoal,
    required this.totalBalls,
    required this.elapsedTime,
    required this.moves,
    required this.ballPositions,
    required this.goalPositions,
  });
}
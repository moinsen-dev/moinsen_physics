import 'package:flame_forge2d/flame_forge2d.dart';
import '../../presentation/components/physics_objects/ball_object.dart';
import '../../presentation/components/physics_objects/obstacle_object.dart';
import '../../presentation/components/physics_objects/goal_object.dart';

/// Manages game state for undo/redo functionality
class GameStateManager {
  static const int maxHistorySize = 20;
  
  final List<GameStateSnapshot> _history = [];
  int _currentIndex = -1;
  
  /// Can undo to previous state
  bool get canUndo => _currentIndex > 0;
  
  /// Can redo to next state
  bool get canRedo => _currentIndex < _history.length - 1;
  
  /// Current state index
  int get currentIndex => _currentIndex;
  
  /// Total states in history
  int get historySize => _history.length;
  
  /// Save current game state
  void saveState(GameStateSnapshot snapshot) {
    // Remove any states after current index (branching history)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
    
    // Add new state
    _history.add(snapshot);
    _currentIndex++;
    
    // Limit history size
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _currentIndex--;
    }
  }
  
  /// Undo to previous state
  GameStateSnapshot? undo() {
    if (!canUndo) return null;
    
    _currentIndex--;
    return _history[_currentIndex];
  }
  
  /// Redo to next state
  GameStateSnapshot? redo() {
    if (!canRedo) return null;
    
    _currentIndex++;
    return _history[_currentIndex];
  }
  
  /// Clear all history
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
  
  /// Get current state
  GameStateSnapshot? get currentState {
    if (_currentIndex < 0 || _currentIndex >= _history.length) return null;
    return _history[_currentIndex];
  }
}

/// Snapshot of game state at a point in time
class GameStateSnapshot {
  final double timestamp;
  final Vector2 gravity;
  final List<BallState> balls;
  final List<ObstacleState> obstacles;
  final List<GoalState> goals;
  final int moves;
  final double timeElapsed;
  final Map<String, dynamic> metadata;
  
  GameStateSnapshot({
    required this.timestamp,
    required this.gravity,
    required this.balls,
    required this.obstacles,
    required this.goals,
    required this.moves,
    required this.timeElapsed,
    this.metadata = const {},
  });
  
  /// Create snapshot from current game objects
  factory GameStateSnapshot.fromGame({
    required Vector2 gravity,
    required List<BallObject> balls,
    required List<ObstacleObject> obstacles,
    required List<GoalObject> goals,
    required int moves,
    required double timeElapsed,
  }) {
    return GameStateSnapshot(
      timestamp: DateTime.now().millisecondsSinceEpoch.toDouble(),
      gravity: gravity.clone(),
      balls: balls.map((ball) => BallState.fromBall(ball)).toList(),
      obstacles: obstacles.map((obs) => ObstacleState.fromObstacle(obs)).toList(),
      goals: goals.map((goal) => GoalState.fromGoal(goal)).toList(),
      moves: moves,
      timeElapsed: timeElapsed,
    );
  }
}

/// State of a ball object
class BallState {
  final Vector2 position;
  final Vector2 velocity;
  final double angle;
  final double angularVelocity;
  final double radius;
  final double mass;
  
  BallState({
    required this.position,
    required this.velocity,
    required this.angle,
    required this.angularVelocity,
    required this.radius,
    required this.mass,
  });
  
  factory BallState.fromBall(BallObject ball) {
    return BallState(
      position: ball.body.position.clone(),
      velocity: ball.body.linearVelocity.clone(),
      angle: ball.body.angle,
      angularVelocity: ball.body.angularVelocity,
      radius: ball.radius,
      mass: ball.mass,
    );
  }
  
  /// Apply state to ball
  void applyTo(BallObject ball) {
    ball.body.setTransform(position, angle);
    ball.body.linearVelocity = velocity.clone();
    ball.body.angularVelocity = angularVelocity;
  }
}

/// State of an obstacle
class ObstacleState {
  final Vector2 position;
  final double angle;
  final bool isStatic;
  
  ObstacleState({
    required this.position,
    required this.angle,
    required this.isStatic,
  });
  
  factory ObstacleState.fromObstacle(ObstacleObject obstacle) {
    return ObstacleState(
      position: obstacle.body.position.clone(),
      angle: obstacle.body.angle,
      isStatic: obstacle.isStatic,
    );
  }
  
  /// Apply state to obstacle
  void applyTo(ObstacleObject obstacle) {
    if (!obstacle.isStatic) {
      obstacle.body.setTransform(position, angle);
    }
  }
}

/// State of a goal
class GoalState {
  final Set<int> ballIndicesInside;
  
  GoalState({
    required this.ballIndicesInside,
  });
  
  factory GoalState.fromGoal(GoalObject goal) {
    // Store indices instead of references
    return GoalState(
      ballIndicesInside: {}, // Will be populated by game
    );
  }
}

/// Command pattern for undoable actions
abstract class GameCommand {
  /// Execute the command
  void execute();
  
  /// Undo the command
  void undo();
  
  /// Get command description
  String get description;
}

/// Gravity change command
class GravityChangeCommand extends GameCommand {
  final Vector2 oldGravity;
  final Vector2 newGravity;
  final Function(Vector2) applyGravity;
  
  GravityChangeCommand({
    required this.oldGravity,
    required this.newGravity,
    required this.applyGravity,
  });
  
  @override
  void execute() {
    applyGravity(newGravity);
  }
  
  @override
  void undo() {
    applyGravity(oldGravity);
  }
  
  @override
  String get description => 'Change gravity';
}
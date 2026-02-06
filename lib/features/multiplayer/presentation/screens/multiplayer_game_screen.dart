import 'dart:async' as async;
import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../data/network/quantum_network_engine.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/entities/network_message.dart';
import '../../../../core/physics/quantum_physics_engine.dart';
import '../../../../core/effects/ultra_visual_effects.dart';
import '../../../game/domain/entities/quantum_game_object.dart';

/// Epic multiplayer game screen with real-time physics synchronization
class MultiplayerGameScreen extends StatefulWidget {
  final GameMode mode;
  final String roomId;
  final QuantumNetworkEngine networkEngine;
  
  const MultiplayerGameScreen({
    super.key,
    required this.mode,
    required this.roomId,
    required this.networkEngine,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  late final MultiplayerQuantumGame game;
  final Map<String, PlayerState> _players = {};
  async.Timer? _syncTimer;
  
  @override
  void initState() {
    super.initState();
    
    game = MultiplayerQuantumGame(
      mode: widget.mode,
      roomId: widget.roomId,
      networkEngine: widget.networkEngine,
    );
    
    // Start sync timer
    _syncTimer = async.Timer.periodic(const Duration(milliseconds: 50), (_) {
      _syncPhysicsState();
    });
  }
  
  void _syncPhysicsState() {
    if (game.world.physicsWorld.bodies.isNotEmpty) {
      widget.networkEngine.sendPhysicsUpdate(
        game.world.physicsWorld.bodies.toList(),
        DateTime.now().millisecondsSinceEpoch.toDouble(),
      );
    }
  }
  
  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game view
          GameWidget(game: game),
          
          // Multiplayer HUD
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _buildMultiplayerHUD(),
          ),
          
          // Player list
          Positioned(
            top: 150,
            right: 20,
            child: _buildPlayerList(),
          ),
          
          // Game mode specific UI
          if (widget.mode == GameMode.gravityWars)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildBattleControls(),
            ),
          
          // Network status
          Positioned(
            top: 50,
            left: 20,
            child: _buildNetworkStatus(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMultiplayerHUD() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getModeColor().withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Room info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ROOM: ${widget.roomId}',
                style: TextStyle(
                  color: _getModeColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                _getModeName(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          // Timer/Score
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  '5:00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Leave button
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: _showLeaveDialog,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerList() {
    return Container(
      width: 200,
      constraints: BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.group, color: Colors.cyan, size: 16),
                SizedBox(width: 8),
                Text(
                  'PLAYERS (${_players.length + 1}/4)',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // You (local player)
          _buildPlayerItem(
            PlayerState(
              id: 'local',
              name: 'You',
              skillRating: 1500,
            ),
            isLocal: true,
          ),
          // Remote players
          ..._players.values.map((player) => _buildPlayerItem(player)),
        ],
      ),
    );
  }
  
  Widget _buildPlayerItem(PlayerState player, {bool isLocal = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Player color indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: player.playerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: player.playerColor.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Player name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name + (isLocal ? ' (You)' : ''),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: isLocal ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      getRankIcon(player.rankTier),
                      color: getRankColor(player.rankTier),
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${player.skillRating}',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score/Status
          if (widget.mode == GameMode.gravityWars)
            Text(
              '${player.score}',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (player.status == PlayerStatus.disconnected)
            Icon(Icons.signal_wifi_off, color: Colors.red, size: 16),
        ],
      ),
    );
  }
  
  Widget _buildBattleControls() {
    return Container(
      height: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBattleButton(
            icon: Icons.rocket_launch,
            label: 'LAUNCH',
            color: Colors.red,
            onPressed: () => game.launchProjectile(),
          ),
          _buildBattleButton(
            icon: Icons.shield,
            label: 'SHIELD',
            color: Colors.blue,
            onPressed: () => game.activateShield(),
          ),
          _buildBattleButton(
            icon: Icons.bolt,
            label: 'POWER',
            color: Colors.yellow,
            onPressed: () => game.usePowerUp(),
          ),
          _buildBattleButton(
            icon: Icons.refresh,
            label: 'FLIP',
            color: Colors.purple,
            onPressed: () => game.flipGravity(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBattleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNetworkStatus() {
    final latency = widget.networkEngine.latency;
    final color = latency < 50 ? Colors.green 
        : latency < 100 ? Colors.yellow 
        : Colors.red;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi, color: color, size: 16),
          SizedBox(width: 4),
          Text(
            '${latency.toInt()}ms',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Leave Match?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'You will forfeit this match if you leave.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('STAY', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('LEAVE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Color _getModeColor() {
    switch (widget.mode) {
      case GameMode.gravityWars:
        return Colors.red;
      case GameMode.quantumRace:
        return Colors.blue;
      case GameMode.cooperativePuzzle:
        return Colors.green;
      case GameMode.battleRoyale:
        return Colors.orange;
    }
  }
  
  String _getModeName() {
    switch (widget.mode) {
      case GameMode.gravityWars:
        return 'Gravity Wars';
      case GameMode.quantumRace:
        return 'Quantum Race';
      case GameMode.cooperativePuzzle:
        return 'Co-op Puzzle';
      case GameMode.battleRoyale:
        return 'Battle Royale';
    }
  }
}

/// Multiplayer game engine with networking
class MultiplayerQuantumGame extends Forge2DGame with TapCallbacks, DragCallbacks {
  final GameMode mode;
  final String roomId;
  final QuantumNetworkEngine networkEngine;
  
  late QuantumPhysicsEngine quantumEngine;
  final List<QuantumGameObject> localObjects = [];
  final Map<String, List<QuantumGameObject>> remoteObjects = {};
  
  // Battle mode specific
  int localScore = 0;
  bool shieldActive = false;
  
  MultiplayerQuantumGame({
    required this.mode,
    required this.roomId,
    required this.networkEngine,
  }) : super(gravity: Vector2(0, 9.81));
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize quantum physics
    quantumEngine = QuantumPhysicsEngine(world);
    
    // Create epic multiplayer background
    add(UltraVisualEffects.createParticleStorm(
      position: size / 2,
      color: _getModeColor().withValues(alpha: 0.2),
      particleCount: 2000,
      radius: size.length,
    ));
    
    // Setup arena
    _createMultiplayerArena();
    
    // Listen for network events
    networkEngine.messages.listen(_handleNetworkEvent);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update quantum physics
    quantumEngine.quantumStep(dt);
    
    // Apply remote player states
    remoteObjects.forEach((playerId, objects) {
      networkEngine.applyRemoteState(playerId, world);
    });
    
    // Check victory conditions
    if (mode == GameMode.gravityWars) {
      _checkBattleVictory();
    }
  }
  
  void _createMultiplayerArena() {
    // Create arena boundaries
    final walls = [
      Vector2(size.x / 2, 10), // Top
      Vector2(size.x / 2, size.y - 10), // Bottom
      Vector2(10, size.y / 2), // Left
      Vector2(size.x - 10, size.y / 2), // Right
    ];
    
    final wallSizes = [
      Vector2(size.x, 20), // Top
      Vector2(size.x, 20), // Bottom
      Vector2(20, size.y), // Left
      Vector2(20, size.y), // Right
    ];
    
    for (int i = 0; i < walls.length; i++) {
      add(_createWall(walls[i], wallSizes[i]));
    }
    
    // Mode-specific setup
    switch (mode) {
      case GameMode.gravityWars:
        _setupGravityWarsArena();
        break;
      case GameMode.quantumRace:
        _setupQuantumRaceTrack();
        break;
      case GameMode.cooperativePuzzle:
        _setupCoopPuzzle();
        break;
      case GameMode.battleRoyale:
        _setupBattleRoyaleZone();
        break;
    }
  }
  
  void _setupGravityWarsArena() {
    // Create player spawn points
    final spawnPoints = [
      Vector2(size.x * 0.2, size.y * 0.5),
      Vector2(size.x * 0.8, size.y * 0.5),
      Vector2(size.x * 0.5, size.y * 0.2),
      Vector2(size.x * 0.5, size.y * 0.8),
    ];
    
    // Spawn local player
    final playerBall = QuantumBall(
      position: spawnPoints[0],
      color: Colors.blue,
      radius: 2.0,
    );
    add(playerBall);
    localObjects.add(playerBall);
    
    // Add power-up spawners
    for (int i = 0; i < 4; i++) {
      final spawner = PowerUpSpawner(
        position: Vector2(
          size.x * (0.25 + i * 0.25),
          size.y * 0.5,
        ),
      );
      add(spawner);
    }
    
    // Add environmental hazards
    add(UltraVisualEffects.createDistortionField(
      center: size / 2,
      radius: 100,
      strength: 0.5,
    ));
  }
  
  void _setupQuantumRaceTrack() {
    // Create race checkpoints
    final checkpoints = [
      Vector2(size.x * 0.2, size.y * 0.8),
      Vector2(size.x * 0.8, size.y * 0.8),
      Vector2(size.x * 0.8, size.y * 0.2),
      Vector2(size.x * 0.2, size.y * 0.2),
    ];
    
    for (final checkpoint in checkpoints) {
      add(RaceCheckpoint(position: checkpoint));
    }
    
    // Add speed boosts
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final pos = size / 2 + Vector2(cos(angle), sin(angle)) * 150;
      add(SpeedBoost(position: pos));
    }
  }
  
  void _setupCoopPuzzle() {
    // Create cooperative elements
    final button1 = CoopButton(
      position: Vector2(size.x * 0.3, size.y * 0.7),
      color: Colors.red,
    );
    final button2 = CoopButton(
      position: Vector2(size.x * 0.7, size.y * 0.7),
      color: Colors.blue,
    );
    
    add(button1);
    add(button2);
    
    // Create door that opens when both buttons pressed
    final door = CoopDoor(
      position: Vector2(size.x * 0.5, size.y * 0.3),
      requiredButtons: [button1, button2],
    );
    add(door);
  }
  
  void _setupBattleRoyaleZone() {
    // Create shrinking zone
    add(ShrinkingZone(
      initialRadius: size.length / 2,
      shrinkRate: 5.0, // pixels per second
    ));
    
    // Spawn loot boxes
    final random = Random();
    for (int i = 0; i < 20; i++) {
      add(LootBox(
        position: Vector2(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        ),
      ));
    }
  }
  
  BodyComponent _createWall(Vector2 position, Vector2 size) {
    return BodyComponent(
      bodyDef: BodyDef()
        ..type = BodyType.static
        ..position = position,
      fixtureDefs: [
        FixtureDef(PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2))
          ..friction = 0.3
          ..restitution = 0.5,
      ],
    );
  }
  
  void _handleNetworkEvent(NetworkMessage message) {
    switch (message.type) {
      case MessageType.gameEvent:
        final event = message.data['event'] as GameEvent;
        _processGameEvent(event);
        break;
      case MessageType.playerJoined:
        _spawnRemotePlayer(message.data['playerId']);
        break;
      case MessageType.playerLeft:
        _removeRemotePlayer(message.data['playerId']);
        break;
      default:
        break;
    }
  }
  
  void _processGameEvent(GameEvent event) {
    switch (event.type) {
      case GameEventType.gravityChange:
        final newGravity = Vector2(
          event.data['x'].toDouble(),
          event.data['y'].toDouble(),
        );
        quantumEngine.baseGravity = newGravity;
        break;
        
      case GameEventType.powerUpCollected:
        add(UltraVisualEffects.createExplosion(
          position: Vector2(
            event.data['x'].toDouble(),
            event.data['y'].toDouble(),
          ),
          color: Colors.yellow,
          intensity: 2.0,
        ));
        break;
        
      default:
        break;
    }
  }
  
  void _spawnRemotePlayer(String playerId) {
    final spawnPos = Vector2(
      size.x * Random().nextDouble(),
      size.y * Random().nextDouble(),
    );
    
    final playerBall = QuantumBall(
      position: spawnPos,
      color: Colors.red,
    );
    playerBall.body.userData = '${playerId}_ball';
    
    add(playerBall);
    remoteObjects.putIfAbsent(playerId, () => []).add(playerBall);
  }
  
  void _removeRemotePlayer(String playerId) {
    final objects = remoteObjects[playerId];
    if (objects != null) {
      for (final obj in objects) {
        remove(obj);
      }
      remoteObjects.remove(playerId);
    }
  }
  
  void _checkBattleVictory() {
    // Check if any player reached score limit
    if (localScore >= 10) {
      _showVictoryScreen();
    }
  }
  
  void _showVictoryScreen() {
    add(VictoryOverlay(
      winner: 'You',
      score: localScore,
    ));
  }
  
  // Battle controls
  void launchProjectile() {
    if (localObjects.isNotEmpty) {
      final launcher = localObjects.first;
      final projectile = EnergyProjectile(
        position: launcher.body.position,
        velocity: Vector2(0, -20),
        owner: 'local',
      );
      add(projectile);
      
      networkEngine.sendGameEvent(GameEvent(
        type: GameEventType.objectCreated,
        data: {
          'type': 'projectile',
          'position': {'x': launcher.body.position.x, 'y': launcher.body.position.y},
          'velocity': {'x': 0, 'y': -20},
        },
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }
  
  void activateShield() {
    if (!shieldActive && localObjects.isNotEmpty) {
      shieldActive = true;
      final shield = EnergyShield(
        target: localObjects.first,
        duration: 5.0,
      );
      add(shield);
      
      Future.delayed(Duration(seconds: 5), () {
        shieldActive = false;
      });
    }
  }
  
  void usePowerUp() {
    add(UltraVisualEffects.createExplosion(
      position: size / 2,
      color: Colors.yellow,
      intensity: 3.0,
    ));
  }
  
  void flipGravity() {
    quantumEngine.baseGravity = -quantumEngine.baseGravity;
    
    networkEngine.sendGameEvent(GameEvent(
      type: GameEventType.gravityChange,
      data: {
        'x': quantumEngine.baseGravity.x,
        'y': quantumEngine.baseGravity.y,
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
  }
  
  Color _getModeColor() {
    switch (mode) {
      case GameMode.gravityWars:
        return Colors.red;
      case GameMode.quantumRace:
        return Colors.blue;
      case GameMode.cooperativePuzzle:
        return Colors.green;
      case GameMode.battleRoyale:
        return Colors.orange;
    }
  }
}

// Additional multiplayer components would go here...
class PowerUpSpawner extends PositionComponent {
  PowerUpSpawner({required Vector2 position}) : super(position: position);
  
  @override
  void update(double dt) {
    super.update(dt);
    // Spawn power-ups periodically
  }
}

class RaceCheckpoint extends PositionComponent {
  bool passed = false;
  
  RaceCheckpoint({required Vector2 position}) : super(position: position);
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = passed ? Colors.green : Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(Offset.zero, 30, paint);
  }
}

class SpeedBoost extends PositionComponent {
  SpeedBoost({required Vector2 position}) : super(position: position);
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    // Draw arrow shape
    final path = Path()
      ..moveTo(0, -20)
      ..lineTo(15, 20)
      ..lineTo(0, 10)
      ..lineTo(-15, 20)
      ..close();
    
    canvas.drawPath(path, paint);
  }
}

class CoopButton extends PositionComponent {
  final Color color;
  bool isPressed = false;
  
  CoopButton({required Vector2 position, required this.color}) 
      : super(position: position);
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = isPressed ? color : color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 25, paint);
  }
  
  void press() {
    isPressed = true;
  }
  
  void release() {
    isPressed = false;
  }
}

class CoopDoor extends PositionComponent {
  final List<CoopButton> requiredButtons;
  bool isOpen = false;
  
  CoopDoor({required Vector2 position, required this.requiredButtons})
      : super(position: position);
  
  @override
  void update(double dt) {
    super.update(dt);
    // Check if all buttons are pressed
    isOpen = requiredButtons.every((button) => button.isPressed);
  }
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = isOpen ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: 60,
      height: isOpen ? 10 : 80,
    );
    
    canvas.drawRect(rect, paint);
  }
}

class ShrinkingZone extends PositionComponent {
  final double initialRadius;
  final double shrinkRate;
  double currentRadius;
  
  ShrinkingZone({required this.initialRadius, required this.shrinkRate})
      : currentRadius = initialRadius,
        super();
  
  @override
  void update(double dt) {
    super.update(dt);
    currentRadius = (currentRadius - shrinkRate * dt).clamp(50, initialRadius);
  }
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, currentRadius, paint);
    
    // Draw border
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.red;
    
    canvas.drawCircle(Offset.zero, currentRadius, paint);
  }
}

class LootBox extends PositionComponent {
  bool isOpened = false;
  
  LootBox({required Vector2 position}) : super(position: position);
  
  @override
  void render(Canvas canvas) {
    if (isOpened) return;
    
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: 30,
      height: 30,
    );
    
    canvas.drawRect(rect, paint);
    
    // Draw question mark
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
  
  void open() {
    isOpened = true;
  }
}

class EnergyProjectile extends BodyComponent {
  final String owner;
  
  EnergyProjectile({
    required Vector2 position,
    required Vector2 velocity,
    required this.owner,
  }) : super(
    bodyDef: BodyDef()
      ..type = BodyType.dynamic
      ..position = position
      ..linearVelocity = velocity,
    fixtureDefs: [
      FixtureDef(
        CircleShape()..radius = 0.5,
      )
        ..density = 0.5
        ..restitution = 0.8,
    ],
  );
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 10, paint);
  }
}

class EnergyShield extends PositionComponent {
  final QuantumGameObject target;
  final double duration;
  double elapsed = 0;
  
  EnergyShield({required this.target, required this.duration}) : super();
  
  @override
  void update(double dt) {
    super.update(dt);
    position = target.body.position;
    elapsed += dt;
    
    if (elapsed >= duration) {
      removeFromParent();
    }
  }
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3 + 0.1 * sin(elapsed * 10))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 40, paint);
    
    // Draw hexagonal pattern
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.cyan;
    
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final start = Offset(cos(angle) * 35, sin(angle) * 35);
      final end = Offset(cos(angle + pi / 3) * 35, sin(angle + pi / 3) * 35);
      canvas.drawLine(start, end, paint);
    }
  }
}

class VictoryOverlay extends PositionComponent {
  final String winner;
  final int score;
  double animationProgress = 0;
  
  VictoryOverlay({required this.winner, required this.score}) : super();
  
  @override
  void update(double dt) {
    super.update(dt);
    animationProgress = (animationProgress + dt).clamp(0, 1);
  }
  
  @override
  void render(Canvas canvas) {
    // Draw background overlay
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8 * animationProgress);
    
    canvas.drawRect(
      Rect.fromLTWH(-1000, -1000, 2000, 2000),
      bgPaint,
    );
    
    // Draw victory text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'VICTORY!\n$winner wins with $score points',
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 48 * animationProgress,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
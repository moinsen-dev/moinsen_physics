import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../domain/entities/network_message.dart';
import '../../domain/entities/player_state.dart';
import '../../../../core/physics/quantum_physics_engine.dart';

/// Revolutionary real-time multiplayer engine with quantum state synchronization
class QuantumNetworkEngine {
  static const String WEBSOCKET_URL = 'wss://gravity-lab.game/quantum';
  static const int TICK_RATE = 60; // 60Hz synchronization
  static const double INTERPOLATION_BUFFER = 100; // ms
  
  WebSocketChannel? _channel;
  final StreamController<NetworkMessage> _messageController = StreamController.broadcast();
  final Map<String, PlayerState> _remotePlayers = {};
  final Map<String, List<PhysicsSnapshot>> _stateBuffer = {};
  
  String? _roomId;
  String? _playerId;
  bool _isHost = false;
  int _sequenceNumber = 0;
  Timer? _syncTimer;
  
  // Lag compensation
  double _serverTime = 0;
  double _clientTime = 0;
  double _roundTripTime = 0;
  final List<double> _rttSamples = [];
  
  // Quantum synchronization
  QuantumPhysicsEngine? _physicsEngine;
  final Map<String, QuantumStateSync> _quantumStates = {};
  
  Stream<NetworkMessage> get messages => _messageController.stream;
  bool get isConnected => _channel != null;
  bool get isHost => _isHost;
  String? get roomId => _roomId;
  double get latency => _roundTripTime / 2;
  
  /// Connect to the multiplayer server
  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(WEBSOCKET_URL));
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
      
      // Send handshake
      _sendMessage(NetworkMessage(
        type: MessageType.handshake,
        data: {
          'version': '2.0',
          'platform': 'mobile',
          'capabilities': ['quantum_sync', 'time_manipulation', 'portal_network'],
        },
      ));
      
      // Start synchronization loop
      _startSyncLoop();
      
    } catch (e) {
      print('Failed to connect: $e');
      throw MultiplayerException('Connection failed: $e');
    }
  }
  
  /// Create a new multiplayer room
  Future<String> createRoom({
    required String roomName,
    required GameMode mode,
    int maxPlayers = 4,
    Map<String, dynamic>? settings,
  }) async {
    final message = NetworkMessage(
      type: MessageType.createRoom,
      data: {
        'name': roomName,
        'mode': mode.toString(),
        'maxPlayers': maxPlayers,
        'settings': settings ?? _getDefaultSettings(mode),
      },
    );
    
    _sendMessage(message);
    
    // Wait for room creation response
    final response = await _waitForResponse(MessageType.roomCreated);
    _roomId = response.data['roomId'];
    _playerId = response.data['playerId'];
    _isHost = true;
    
    return _roomId!;
  }
  
  /// Join an existing room
  Future<void> joinRoom(String roomId) async {
    _sendMessage(NetworkMessage(
      type: MessageType.joinRoom,
      data: {'roomId': roomId},
    ));
    
    final response = await _waitForResponse(MessageType.roomJoined);
    _roomId = roomId;
    _playerId = response.data['playerId'];
    _isHost = false;
    
    // Sync with host state
    _requestStateSync();
  }
  
  /// Send physics state update
  void sendPhysicsUpdate(List<Body> bodies, double timestamp) {
    if (!isConnected || _roomId == null) return;
    
    final snapshot = PhysicsSnapshot(
      timestamp: timestamp,
      sequenceNumber: _sequenceNumber++,
      bodies: bodies.map((body) => BodyState(
        id: body.userData?.toString() ?? '',
        position: body.position,
        velocity: body.linearVelocity,
        angle: body.angle,
        angularVelocity: body.angularVelocity,
      )).toList(),
    );
    
    _sendMessage(NetworkMessage(
      type: MessageType.physicsUpdate,
      data: {
        'snapshot': snapshot.toJson(),
        'roomId': _roomId,
        'playerId': _playerId,
      },
    ));
  }
  
  /// Send quantum state synchronization
  void sendQuantumState(String objectId, QuantumState state) {
    if (!isConnected) return;
    
    _sendMessage(NetworkMessage(
      type: MessageType.quantumSync,
      data: {
        'objectId': objectId,
        'state': {
          'position': {'x': state.position.x, 'y': state.position.y},
          'probability': state.probability,
          'phase': state.phase,
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));
  }
  
  /// Send special event (portal creation, time manipulation, etc.)
  void sendGameEvent(GameEvent event) {
    if (!isConnected) return;
    
    _sendMessage(NetworkMessage(
      type: MessageType.gameEvent,
      data: {
        'event': event.type.toString(),
        'data': event.data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));
  }
  
  /// Apply remote physics state with interpolation
  void applyRemoteState(String playerId, Forge2DWorld world) {
    final buffer = _stateBuffer[playerId];
    if (buffer == null || buffer.length < 2) return;
    
    // Find two states to interpolate between
    final currentTime = DateTime.now().millisecondsSinceEpoch - INTERPOLATION_BUFFER;
    PhysicsSnapshot? from;
    PhysicsSnapshot? to;
    
    for (int i = 0; i < buffer.length - 1; i++) {
      if (buffer[i].timestamp <= currentTime && buffer[i + 1].timestamp > currentTime) {
        from = buffer[i];
        to = buffer[i + 1];
        break;
      }
    }
    
    if (from != null && to != null) {
      // Interpolate between states
      final alpha = (currentTime - from.timestamp) / (to.timestamp - from.timestamp);
      
      for (int i = 0; i < from.bodies.length; i++) {
        final fromBody = from.bodies[i];
        final toBody = to.bodies[i];
        
        // Find corresponding body in world
        for (final body in world.physicsWorld.bodies) {
          if (body.userData == '${playerId}_${fromBody.id}') {
            // Interpolate position
            final interpPos = fromBody.position + (toBody.position - fromBody.position) * alpha;
            final interpAngle = _lerpAngle(fromBody.angle, toBody.angle, alpha);
            
            body.setTransform(interpPos, interpAngle);
            
            // Interpolate velocity for smoother motion
            final interpVel = fromBody.velocity + (toBody.velocity - fromBody.velocity) * alpha;
            body.linearVelocity = interpVel;
          }
        }
      }
    }
    
    // Clean old states
    buffer.removeWhere((state) => state.timestamp < currentTime - 1000);
  }
  
  /// Start matchmaking for ranked games
  Future<void> startMatchmaking({
    required GameMode mode,
    required int skillRating,
  }) async {
    _sendMessage(NetworkMessage(
      type: MessageType.startMatchmaking,
      data: {
        'mode': mode.toString(),
        'skillRating': skillRating,
        'region': _detectRegion(),
      },
    ));
    
    // Wait for match found
    final response = await _waitForResponse(MessageType.matchFound);
    final roomId = response.data['roomId'];
    await joinRoom(roomId);
  }
  
  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data);
      final message = NetworkMessage.fromJson(json);
      
      switch (message.type) {
        case MessageType.playerJoined:
          _handlePlayerJoined(message);
          break;
          
        case MessageType.playerLeft:
          _handlePlayerLeft(message);
          break;
          
        case MessageType.physicsUpdate:
          _handlePhysicsUpdate(message);
          break;
          
        case MessageType.quantumSync:
          _handleQuantumSync(message);
          break;
          
        case MessageType.gameEvent:
          _handleGameEvent(message);
          break;
          
        case MessageType.ping:
          _handlePing(message);
          break;
          
        case MessageType.serverTime:
          _syncServerTime(message);
          break;
          
        default:
          _messageController.add(message);
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }
  
  void _handlePhysicsUpdate(NetworkMessage message) {
    final playerId = message.data['playerId'];
    final snapshot = PhysicsSnapshot.fromJson(message.data['snapshot']);
    
    // Add to interpolation buffer
    _stateBuffer.putIfAbsent(playerId, () => []).add(snapshot);
    
    // Sort by timestamp
    _stateBuffer[playerId]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  void _handleQuantumSync(NetworkMessage message) {
    final objectId = message.data['objectId'];
    final stateData = message.data['state'];
    
    _quantumStates[objectId] = QuantumStateSync(
      isInSuperposition: stateData['superposition'],
      positions: (stateData['positions'] as List)
          .map((p) => Vector2(p['x'].toDouble(), p['y'].toDouble()))
          .toList(),
      probabilities: List<double>.from(stateData['probabilities']),
      phase: stateData['phase'].toDouble(),
    );
    
    // Apply to physics engine if available
    _physicsEngine?.applyRemoteQuantumState(objectId, _quantumStates[objectId]!);
  }
  
  void _handleGameEvent(NetworkMessage message) {
    final event = GameEvent(
      type: GameEventType.values.firstWhere(
        (e) => e.toString() == message.data['event'],
      ),
      data: message.data['data'],
      timestamp: message.data['timestamp'],
    );
    
    _messageController.add(NetworkMessage(
      type: MessageType.gameEvent,
      data: {'event': event},
    ));
  }
  
  void _handlePing(NetworkMessage message) {
    _sendMessage(NetworkMessage(
      type: MessageType.pong,
      data: {'timestamp': message.data['timestamp']},
    ));
  }
  
  void _syncServerTime(NetworkMessage message) {
    final serverTime = message.data['serverTime'].toDouble();
    final localTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    
    // Update RTT samples
    if (message.data['rtt'] != null) {
      _rttSamples.add(message.data['rtt'].toDouble());
      if (_rttSamples.length > 10) {
        _rttSamples.removeAt(0);
      }
      _roundTripTime = _rttSamples.reduce((a, b) => a + b) / _rttSamples.length;
    }
    
    // Adjust server time with latency compensation
    _serverTime = serverTime + latency;
    _clientTime = localTime;
  }
  
  void _handlePlayerJoined(NetworkMessage message) {
    final playerId = message.data['playerId'];
    _remotePlayers[playerId] = PlayerState(
      id: playerId,
      name: message.data['name'],
      avatar: message.data['avatar'],
      skillRating: message.data['skillRating'] ?? 1000,
    );
    
    _messageController.add(message);
  }
  
  void _handlePlayerLeft(NetworkMessage message) {
    final playerId = message.data['playerId'];
    _remotePlayers.remove(playerId);
    _stateBuffer.remove(playerId);
    _messageController.add(message);
  }
  
  void _sendMessage(NetworkMessage message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message.toJson()));
    }
  }
  
  Future<NetworkMessage> _waitForResponse(MessageType type, {Duration timeout = const Duration(seconds: 5)}) {
    return messages
        .where((msg) => msg.type == type)
        .first
        .timeout(timeout, onTimeout: () {
      throw TimeoutException('Response timeout for $type');
    });
  }
  
  void _startSyncLoop() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ TICK_RATE), (timer) {
      // Send periodic ping for latency measurement
      if (_sequenceNumber % 60 == 0) {
        _sendMessage(NetworkMessage(
          type: MessageType.ping,
          data: {'timestamp': DateTime.now().millisecondsSinceEpoch},
        ));
      }
    });
  }
  
  void _requestStateSync() {
    _sendMessage(NetworkMessage(
      type: MessageType.requestSync,
      data: {'roomId': _roomId},
    ));
  }
  
  double _lerpAngle(double from, double to, double t) {
    double difference = to - from;
    while (difference > pi) difference -= 2 * pi;
    while (difference < -pi) difference += 2 * pi;
    return from + difference * t;
  }
  
  String _detectRegion() {
    // Simple region detection based on timezone
    final offset = DateTime.now().timeZoneOffset.inHours;
    if (offset >= -5 && offset <= -3) return 'us-east';
    if (offset >= -8 && offset <= -6) return 'us-west';
    if (offset >= 0 && offset <= 2) return 'eu-west';
    if (offset >= 8 && offset <= 10) return 'asia-east';
    return 'global';
  }
  
  Map<String, dynamic> _getDefaultSettings(GameMode mode) {
    switch (mode) {
      case GameMode.gravityWars:
        return {
          'timeLimit': 300,
          'respawns': 3,
          'powerUps': true,
          'quantumEffects': true,
        };
      case GameMode.quantumRace:
        return {
          'laps': 3,
          'checkpoints': true,
          'ghostMode': true,
        };
      case GameMode.cooperativePuzzle:
        return {
          'difficulty': 'medium',
          'hints': true,
          'syncRequired': true,
        };
      case GameMode.battleRoyale:
        return {
          'startingPlayers': 20,
          'shrinkingZone': true,
          'lastManStanding': true,
        };
      default:
        return {};
    }
  }
  
  void _handleError(error) {
    print('WebSocket error: $error');
    _messageController.addError(error);
  }
  
  void _handleDisconnect() {
    print('WebSocket disconnected');
    _syncTimer?.cancel();
    _channel = null;
    _messageController.add(NetworkMessage(
      type: MessageType.disconnected,
      data: {'reason': 'Connection lost'},
    ));
  }
  
  void dispose() {
    _syncTimer?.cancel();
    _channel?.sink.close();
    _messageController.close();
  }
}

/// Game modes
enum GameMode {
  gravityWars,
  quantumRace,
  cooperativePuzzle,
  battleRoyale,
}

/// Game event types
enum GameEventType {
  gravityChange,
  portalCreated,
  timeRewind,
  quantumCollapse,
  powerUpCollected,
  objectDestroyed,
  objectCreated,
  victoryConditionMet,
}

/// Physics snapshot for synchronization
class PhysicsSnapshot {
  final double timestamp;
  final int sequenceNumber;
  final List<BodyState> bodies;
  
  PhysicsSnapshot({
    required this.timestamp,
    required this.sequenceNumber,
    required this.bodies,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'sequenceNumber': sequenceNumber,
    'bodies': bodies.map((b) => b.toJson()).toList(),
  };
  
  factory PhysicsSnapshot.fromJson(Map<String, dynamic> json) {
    return PhysicsSnapshot(
      timestamp: json['timestamp'].toDouble(),
      sequenceNumber: json['sequenceNumber'],
      bodies: (json['bodies'] as List)
          .map((b) => BodyState.fromJson(b))
          .toList(),
    );
  }
}

/// Body state for synchronization
class BodyState {
  final String id;
  final Vector2 position;
  final Vector2 velocity;
  final double angle;
  final double angularVelocity;
  
  BodyState({
    required this.id,
    required this.position,
    required this.velocity,
    required this.angle,
    required this.angularVelocity,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'position': {'x': position.x, 'y': position.y},
    'velocity': {'x': velocity.x, 'y': velocity.y},
    'angle': angle,
    'angularVelocity': angularVelocity,
  };
  
  factory BodyState.fromJson(Map<String, dynamic> json) {
    return BodyState(
      id: json['id'],
      position: Vector2(
        json['position']['x'].toDouble(),
        json['position']['y'].toDouble(),
      ),
      velocity: Vector2(
        json['velocity']['x'].toDouble(),
        json['velocity']['y'].toDouble(),
      ),
      angle: json['angle'].toDouble(),
      angularVelocity: json['angularVelocity'].toDouble(),
    );
  }
}

/// Quantum state synchronization
class QuantumStateSync {
  final bool isInSuperposition;
  final List<Vector2> positions;
  final List<double> probabilities;
  final double phase;
  
  QuantumStateSync({
    required this.isInSuperposition,
    required this.positions,
    required this.probabilities,
    required this.phase,
  });
}

/// Game event
class GameEvent {
  final GameEventType type;
  final Map<String, dynamic> data;
  final int timestamp;
  
  GameEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

/// Multiplayer exception
class MultiplayerException implements Exception {
  final String message;
  MultiplayerException(this.message);
  
  @override
  String toString() => 'MultiplayerException: $message';
}

// Extension for QuantumPhysicsEngine
extension MultiplayerSync on QuantumPhysicsEngine {
  void applyRemoteQuantumState(String objectId, QuantumStateSync state) {
    // Implementation would go in the actual physics engine
    // This is just to show the integration point
  }
}
/// Network message structure for multiplayer communication
class NetworkMessage {
  final MessageType type;
  final Map<String, dynamic> data;
  final int? sequenceNumber;
  final int? timestamp;
  
  NetworkMessage({
    required this.type,
    required this.data,
    this.sequenceNumber,
    this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'data': data,
    if (sequenceNumber != null) 'sequenceNumber': sequenceNumber,
    'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
  };
  
  factory NetworkMessage.fromJson(Map<String, dynamic> json) {
    return NetworkMessage(
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      data: json['data'] ?? {},
      sequenceNumber: json['sequenceNumber'],
      timestamp: json['timestamp'],
    );
  }
}

enum MessageType {
  handshake,
  createRoom,
  roomCreated,
  joinRoom,
  roomJoined,
  playerJoined,
  playerLeft,
  physicsUpdate,
  quantumSync,
  gameEvent,
  ping,
  pong,
  serverTime,
  requestSync,
  startMatchmaking,
  matchFound,
  disconnected,
}
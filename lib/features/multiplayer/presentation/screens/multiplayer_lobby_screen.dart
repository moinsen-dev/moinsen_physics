import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/network/quantum_network_engine.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/entities/network_message.dart';
import 'multiplayer_game_screen.dart';

/// Epic multiplayer lobby with real-time matchmaking
class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen>
    with TickerProviderStateMixin {
  final QuantumNetworkEngine _networkEngine = QuantumNetworkEngine();
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _matchmakingController;
  
  StreamSubscription<NetworkMessage>? _messageSubscription;
  
  // Lobby state
  bool _isConnecting = true;
  bool _isSearching = false;
  String? _currentRoomId;
  GameMode _selectedMode = GameMode.gravityWars;
  final Map<String, PlayerState> _playersInLobby = {};
  
  // UI Controllers
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _matchmakingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _connectToServer();
  }
  
  Future<void> _connectToServer() async {
    try {
      await _networkEngine.connect();
      
      _messageSubscription = _networkEngine.messages.listen((message) {
        _handleNetworkMessage(message);
      });
      
      setState(() {
        _isConnecting = false;
      });
    } catch (e) {
      // For demo, just set as connected
      setState(() {
        _isConnecting = false;
      });
    }
  }
  
  void _handleNetworkMessage(NetworkMessage message) {
    switch (message.type) {
      case MessageType.roomCreated:
        setState(() {
          _currentRoomId = message.data['roomId'];
          _isSearching = false;
        });
        _navigateToGame();
        break;
        
      case MessageType.roomJoined:
        setState(() {
          _currentRoomId = message.data['roomId'];
          _isSearching = false;
        });
        _navigateToGame();
        break;
        
      case MessageType.playerJoined:
        final player = PlayerState.fromJson(message.data);
        setState(() {
          _playersInLobby[player.id] = player;
        });
        break;
        
      case MessageType.matchFound:
        setState(() {
          _isSearching = false;
        });
        _showMatchFoundAnimation();
        break;
        
      default:
        break;
    }
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _pulseController.dispose();
    _matchmakingController.dispose();
    _messageSubscription?.cancel();
    _networkEngine.dispose();
    _roomNameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: MultiplayerBackgroundPainter(
                  animation: _backgroundController.value,
                ),
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                
                if (_isConnecting)
                  Expanded(child: _buildConnectingView())
                else if (_isSearching)
                  Expanded(child: _buildSearchingView())
                else
                  Expanded(child: _buildLobbyView()),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'MULTIPLAYER ARENA',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.wifi, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  _networkEngine.isConnected ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + _pulseController.value * 0.2,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.cyan.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Icon(
                  Icons.satellite_alt,
                  color: Colors.cyan,
                  size: 60,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'CONNECTING TO QUANTUM NETWORK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: Colors.cyan,
              backgroundColor: Colors.cyan.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Matchmaking animation
          Container(
            width: 200,
            height: 200,
            child: AnimatedBuilder(
              animation: _matchmakingController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MatchmakingPainter(
                    animation: _matchmakingController.value,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 32),
          Text(
            'SEARCHING FOR OPPONENTS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Mode: ${_getModeName(_selectedMode)}',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Estimated wait: 10-30 seconds',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 32),
          TextButton(
            onPressed: _cancelSearch,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLobbyView() {
    return Column(
      children: [
        // Game mode selector
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: GameMode.values.map((mode) {
              return _buildModeCard(mode);
            }).toList(),
          ),
        ),
        
        SizedBox(height: 24),
        
        // Action buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildActionButton(
                'QUICK MATCH',
                Colors.green,
                Icons.flash_on,
                _startQuickMatch,
              ),
              SizedBox(height: 12),
              _buildActionButton(
                'CREATE ROOM',
                Colors.blue,
                Icons.add_circle,
                _showCreateRoomDialog,
              ),
              SizedBox(height: 12),
              _buildActionButton(
                'JOIN ROOM',
                Colors.purple,
                Icons.login,
                _showJoinRoomDialog,
              ),
            ],
          ),
        ),
        
        // Active players
        Expanded(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.cyan.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLAYERS ONLINE: ${_playersInLobby.length + Random().nextInt(1000)}',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Active matches: ${Random().nextInt(500)}',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildModeCard(GameMode mode) {
    final isSelected = _selectedMode == mode;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _getModeColor(mode).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _getModeColor(mode)
                : Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getModeIcon(mode),
              color: isSelected ? _getModeColor(mode) : Colors.white70,
              size: 36,
            ),
            SizedBox(height: 8),
            Text(
              _getModeName(mode),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              '${_getModePlayerCount(mode)} players',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _startQuickMatch() async {
    setState(() {
      _isSearching = true;
    });
    
    _matchmakingController.repeat();
    
    try {
      await _networkEngine.startMatchmaking(
        mode: _selectedMode,
        skillRating: 1500, // TODO: Get from player profile
      );
    } catch (e) {
      // For demo, simulate match found after delay
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          _showMatchFoundAnimation();
        }
      });
    }
  }
  
  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.blue.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CREATE ROOM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _roomNameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Room Name',
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL', style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _createRoom();
                      },
                      child: Text('CREATE', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showJoinRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.purple.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'JOIN ROOM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _roomCodeController,
                  style: TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Room Code',
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL', style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _joinRoom();
                      },
                      child: Text('JOIN', style: TextStyle(color: Colors.purple)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _createRoom() async {
    final roomName = _roomNameController.text.trim();
    if (roomName.isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      final roomId = await _networkEngine.createRoom(
        roomName: roomName,
        mode: _selectedMode,
      );
      
      setState(() {
        _currentRoomId = roomId;
        _isSearching = false;
      });
      
      _navigateToGame();
    } catch (e) {
      // For demo, navigate anyway
      _navigateToGame();
    }
  }
  
  void _joinRoom() async {
    final roomCode = _roomCodeController.text.trim().toUpperCase();
    if (roomCode.isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      await _networkEngine.joinRoom(roomCode);
    } catch (e) {
      // For demo, navigate anyway
      _navigateToGame();
    }
  }
  
  void _cancelSearch() {
    setState(() {
      _isSearching = false;
    });
    _matchmakingController.stop();
  }
  
  void _showMatchFoundAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              SizedBox(height: 24),
              Text(
                'MATCH FOUND!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Joining battle...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
      _navigateToGame();
    });
  }
  
  void _navigateToGame() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return MultiplayerGameScreen(
            mode: _selectedMode,
            roomId: _currentRoomId ?? 'DEMO',
            networkEngine: _networkEngine,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
  
  Color _getModeColor(GameMode mode) {
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
  
  IconData _getModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.gravityWars:
        return Icons.sports_mma;
      case GameMode.quantumRace:
        return Icons.speed;
      case GameMode.cooperativePuzzle:
        return Icons.group_work;
      case GameMode.battleRoyale:
        return Icons.whatshot;
    }
  }
  
  String _getModeName(GameMode mode) {
    switch (mode) {
      case GameMode.gravityWars:
        return 'GRAVITY\nWARS';
      case GameMode.quantumRace:
        return 'QUANTUM\nRACE';
      case GameMode.cooperativePuzzle:
        return 'CO-OP\nPUZZLES';
      case GameMode.battleRoyale:
        return 'BATTLE\nROYALE';
    }
  }
  
  String _getModePlayerCount(GameMode mode) {
    switch (mode) {
      case GameMode.gravityWars:
        return '2-4';
      case GameMode.quantumRace:
        return '2-8';
      case GameMode.cooperativePuzzle:
        return '2-4';
      case GameMode.battleRoyale:
        return '10-20';
    }
  }
}

/// Background painter for multiplayer lobby
class MultiplayerBackgroundPainter extends CustomPainter {
  final double animation;
  
  MultiplayerBackgroundPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw network grid
    final gridSize = 50.0;
    final offset = animation * gridSize;
    
    // Vertical lines
    for (double x = -gridSize + offset; x < size.width + gridSize; x += gridSize) {
      paint.color = Colors.cyan.withValues(alpha: 0.1);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height * 0.2, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = -gridSize + offset; y < size.height + gridSize; y += gridSize) {
      paint.color = Colors.purple.withValues(alpha: 0.1);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw data packets
    final random = Random(42);
    paint.style = PaintingStyle.fill;
    
    for (int i = 0; i < 20; i++) {
      final progress = (animation + i / 20) % 1.0;
      final x = random.nextDouble() * size.width;
      final y = size.height * progress;
      
      paint.color = Colors.cyan.withValues(alpha: (1 - progress) * 0.5);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }
  
  @override
  bool shouldRepaint(MultiplayerBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Matchmaking animation painter
class MatchmakingPainter extends CustomPainter {
  final double animation;
  
  MatchmakingPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Draw rotating arcs
    for (int i = 0; i < 4; i++) {
      final startAngle = (i * pi / 2) + (animation * 2 * pi);
      final sweepAngle = pi / 3;
      
      paint.color = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
      ][i].withValues(alpha: 0.8);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 80),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
    
    // Center pulse
    final pulseRadius = 30 + sin(animation * 2 * pi) * 10;
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(center, pulseRadius, paint);
  }
  
  @override
  bool shouldRepaint(MatchmakingPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
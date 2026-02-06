import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/world.dart';
import '../../data/world1_levels.dart';
import '../providers/level_providers.dart';
import '../../../progress/progress_service.dart';
import 'level_selection_screen.dart';

/// Epic world selection screen for Gravity Lab 2.0
class WorldSelectionScreen extends ConsumerStatefulWidget {
  const WorldSelectionScreen({super.key});

  @override
  ConsumerState<WorldSelectionScreen> createState() => _WorldSelectionScreenState();
}

class _WorldSelectionScreenState extends ConsumerState<WorldSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _carouselController;
  late PageController _pageController;
  
  List<World> _worlds = [];
  int _currentWorldIndex = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: 0,
    );
    
    _loadWorlds();
  }
  
  Future<void> _loadWorlds() async {
    try {
      final repository = ref.read(levelRepositoryProvider);
      final worlds = await repository.loadAllWorlds();
      setState(() {
        _worlds = worlds;
        _isLoading = false;
      });
      _carouselController.forward();
    } catch (e) {
      // For demo, create mock worlds
      setState(() {
        _worlds = _createMockWorlds();
        _isLoading = false;
      });
      _carouselController.forward();
    }
  }
  
  List<World> _createMockWorlds() {
    // Get actual levels for World 1
    final world1Levels = [
      ...World1Levels.getLevels(),
      ...World1Levels.generateRemainingLevels(),
    ]..sort((a, b) => a.levelNumber.compareTo(b.levelNumber));

    return [
      World(
        id: 1,
        name: "Newton's Laboratory",
        description: "Master the basics of gravity manipulation",
        theme: "classical",
        visuals: WorldVisuals(
          primaryColor: Colors.blue,
          secondaryColor: Colors.lightBlue,
          accentColor: Colors.cyan,
          backgroundAsset: "newton_lab.jpg",
          musicTrack: "classical_physics.mp3",
          lighting: LightingConfig(
            ambientColor: Colors.white,
            ambientIntensity: 0.8,
          ),
        ),
        levels: world1Levels,
        unlockRequirement: StarRequirement(requiredStars: 0),
      )..isUnlocked = true, // World 1 is always unlocked
      World(
        id: 2,
        name: "Zero-G Station",
        description: "Navigate the mysteries of weightlessness",
        theme: "space",
        visuals: WorldVisuals(
          primaryColor: Colors.purple,
          secondaryColor: Colors.deepPurple,
          accentColor: Colors.purpleAccent,
          backgroundAsset: "space_station.jpg",
          musicTrack: "zero_gravity.mp3",
          lighting: LightingConfig(
            ambientColor: Colors.deepPurple,
            ambientIntensity: 0.6,
          ),
        ),
        levels: [],
        unlockRequirement: StarRequirement(requiredStars: 30),
      ),
      World(
        id: 3,
        name: "Quantum Realm",
        description: "Where reality bends and possibilities multiply",
        theme: "quantum",
        visuals: WorldVisuals(
          primaryColor: Colors.green,
          secondaryColor: Colors.teal,
          accentColor: Colors.greenAccent,
          backgroundAsset: "quantum_realm.jpg",
          musicTrack: "quantum_mechanics.mp3",
          lighting: LightingConfig(
            ambientColor: Colors.teal,
            ambientIntensity: 0.7,
          ),
        ),
        levels: [],
        unlockRequirement: StarRequirement(requiredStars: 60),
      ),
      World(
        id: 4,
        name: "Time Laboratory",
        description: "Control the flow of time itself",
        theme: "temporal",
        visuals: WorldVisuals(
          primaryColor: Colors.orange,
          secondaryColor: Colors.deepOrange,
          accentColor: Colors.amber,
          backgroundAsset: "time_lab.jpg",
          musicTrack: "temporal_flux.mp3",
          lighting: LightingConfig(
            ambientColor: Colors.amber,
            ambientIntensity: 0.7,
          ),
        ),
        levels: [],
        unlockRequirement: StarRequirement(requiredStars: 90),
      ),
      World(
        id: 5,
        name: "Magnetic Fields",
        description: "Harness the power of attraction and repulsion",
        theme: "magnetic",
        visuals: WorldVisuals(
          primaryColor: Colors.red,
          secondaryColor: Colors.pink,
          accentColor: Colors.redAccent,
          backgroundAsset: "magnetic_field.jpg",
          musicTrack: "electromagnetic.mp3",
          lighting: LightingConfig(
            ambientColor: Colors.red,
            ambientIntensity: 0.6,
          ),
        ),
        levels: [],
        unlockRequirement: StarRequirement(requiredStars: 120),
      ),
      World(
        id: 6,
        name: "Chaos Dimension",
        description: "The ultimate test of physics mastery",
        theme: "chaos",
        visuals: WorldVisuals(
          primaryColor: Colors.deepPurple,
          secondaryColor: Colors.black,
          accentColor: Colors.purpleAccent,
          backgroundAsset: "chaos_dimension.jpg",
          musicTrack: "chaos_theory.mp3",
          lighting: LightingConfig(
            ambientColor: Colors.deepPurple,
            ambientIntensity: 0.4,
          ),
        ),
        levels: [],
        unlockRequirement: BossRequirement(bossWorldId: 5),
      ),
    ];
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _carouselController.dispose();
    _pageController.dispose();
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
                painter: WorldBackgroundPainter(
                  animation: _backgroundController.value,
                  currentWorld: _currentWorldIndex < _worlds.length
                      ? _worlds[_currentWorldIndex]
                      : null,
                ),
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'SELECT WORLD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '${ref.watch(progressServiceProvider).totalStarsEarned}',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // World carousel
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.cyan,
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentWorldIndex = index;
                            });
                          },
                          itemCount: _worlds.length,
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _carouselController,
                              builder: (context, child) {
                                final scale = _currentWorldIndex == index
                                    ? 1.0
                                    : 0.8;
                                    
                                return Transform.scale(
                                  scale: scale * _carouselController.value,
                                  child: _buildWorldCard(_worlds[index], index),
                                );
                              },
                            );
                          },
                        ),
                ),
                
                // World info
                if (!_isLoading && _worlds.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          _worlds[_currentWorldIndex].name.toUpperCase(),
                          style: TextStyle(
                            color: _worlds[_currentWorldIndex].visuals.primaryColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _worlds[_currentWorldIndex].description,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        _buildWorldStats(_worlds[_currentWorldIndex]),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorldCard(World world, int index) {
    final isLocked = !world.isUnlocked;
    
    return GestureDetector(
      onTap: isLocked
          ? () => _showLockedDialog(world)
          : () => _navigateToLevelSelection(world),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: world.visuals.primaryColor.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // World preview image
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      world.visuals.primaryColor,
                      world.visuals.secondaryColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getWorldIcon(world.theme),
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              
              // Particle effects
              if (!isLocked)
                Positioned.fill(
                  child: CustomPaint(
                    painter: WorldParticlePainter(
                      color: world.visuals.accentColor,
                      animation: _backgroundController.value,
                    ),
                  ),
                ),
              
              // Lock overlay
              if (isLocked)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 80,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'LOCKED',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            world.unlockRequirement.description,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Progress indicator
              if (!isLocked && world.levels.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: world.completionPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: world.visuals.accentColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: world.visuals.accentColor,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWorldStats(World world) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat(
          icon: Icons.extension,
          value: '${world.levels.length}',
          label: 'LEVELS',
          color: Colors.blue,
        ),
        _buildStat(
          icon: Icons.star,
          value: '${world.totalStarsEarned}/${world.totalPossibleStars}',
          label: 'STARS',
          color: Colors.yellow,
        ),
        _buildStat(
          icon: Icons.trending_up,
          value: world.difficultyDescription,
          label: 'DIFFICULTY',
          color: Colors.red,
        ),
      ],
    );
  }
  
  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  IconData _getWorldIcon(String theme) {
    switch (theme) {
      case 'classical': return Icons.science;
      case 'space': return Icons.rocket_launch;
      case 'quantum': return Icons.blur_on;
      case 'temporal': return Icons.access_time;
      case 'magnetic': return Icons.electrical_services;
      case 'chaos': return Icons.shuffle;
      default: return Icons.public;
    }
  }
  
  void _showLockedDialog(World world) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: world.visuals.primaryColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: world.visuals.primaryColor,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'WORLD LOCKED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  world.unlockRequirement.description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: world.visuals.primaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: world.visuals.primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _navigateToLevelSelection(World world) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return LevelSelectionScreen(world: world);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.9,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}

/// Background painter for world selection
class WorldBackgroundPainter extends CustomPainter {
  final double animation;
  final World? currentWorld;
  
  WorldBackgroundPainter({
    required this.animation,
    this.currentWorld,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (currentWorld == null) return;
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;
    
    // Animated gradient background
    paint.shader = RadialGradient(
      center: Alignment(
        sin(animation * 2 * pi) * 0.5,
        cos(animation * 2 * pi) * 0.5,
      ),
      radius: 1.5,
      colors: [
        currentWorld!.visuals.primaryColor.withValues(alpha: 0.3),
        currentWorld!.visuals.secondaryColor.withValues(alpha: 0.2),
        Colors.transparent,
      ],
      stops: [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(WorldBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.currentWorld != currentWorld;
  }
}

/// Particle painter for world cards
class WorldParticlePainter extends CustomPainter {
  final Color color;
  final double animation;
  final Random random = Random();
  
  WorldParticlePainter({
    required this.color,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..blendMode = BlendMode.plus;
    
    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final progress = (animation + i / 20) % 1.0;
      final y = size.height * (1 - progress);
      final x = size.width * (0.5 + sin(progress * 2 * pi + i) * 0.3);
      final opacity = sin(progress * pi);
      
      paint.color = color.withValues(alpha: opacity * 0.5);
      canvas.drawCircle(
        Offset(x, y),
        2 + random.nextDouble() * 2,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(WorldParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
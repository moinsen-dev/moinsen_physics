import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/world.dart';
import '../../domain/entities/level.dart';
import '../../../game/presentation/screens/main_game_screen.dart';

/// Level selection screen showing all levels in a world
class LevelSelectionScreen extends StatefulWidget {
  final World world;
  
  const LevelSelectionScreen({
    super.key,
    required this.world,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _levelAnimations;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Create staggered animations for each level
    _levelAnimations = List.generate(20, (index) {
      final start = (index * 0.05).clamp(0.0, 1.0);
      final end = (start + 0.3).clamp(0.0, 1.0);
      
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      ));
    });
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.world.visuals.primaryColor.withValues(alpha: 0.3),
              Colors.black,
              widget.world.visuals.secondaryColor.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Level grid
              Expanded(
                child: _buildLevelGrid(),
              ),
              
              // World progress
              _buildWorldProgress(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.world.name.toUpperCase(),
                      style: TextStyle(
                        color: widget.world.visuals.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'WORLD ${widget.world.id}',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${widget.world.totalStarsEarned}/${widget.world.totalPossibleStars}',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            widget.world.description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelGrid() {
    final levelCount = widget.world.levels.length;
    final itemCount = levelCount > 0 ? levelCount : 20;
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final level = index < levelCount ? widget.world.levels[index] : null;
        if (index < _levelAnimations.length) {
          return AnimatedBuilder(
            animation: _levelAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _levelAnimations[index].value,
                child: _buildLevelTile(index + 1, level),
              );
            },
          );
        }
        return _buildLevelTile(index + 1, level);
      },
    );
  }
  
  Widget _buildLevelTile(int levelNumber, Level? levelOrNull) {
    // Use actual level if available, otherwise create placeholder
    final level = levelOrNull ?? Level(
      id: '${widget.world.id}-$levelNumber',
      name: 'Level $levelNumber',
      description: 'Challenge $levelNumber',
      worldId: widget.world.id,
      levelNumber: levelNumber,
      difficulty: _getLevelDifficulty(levelNumber),
      objects: [],
      victoryConditions: [],
      physicsConfig: PhysicsConfig(),
      visualTheme: VisualTheme(
        backgroundType: 'default',
        colorPalette: [widget.world.visuals.primaryColor],
      ),
    );

    // All levels with objects are playable, unlock progressively
    final hasContent = level.objects.isNotEmpty;
    final isUnlocked = hasContent && levelNumber <= 20;
    final isCompleted = level.isCompleted;
    final stars = level.starsEarned;
    final isBossLevel = levelNumber % 5 == 0;
    
    return GestureDetector(
      onTap: isUnlocked
          ? () => _navigateToLevel(level)
          : () => _showLockedLevelDialog(),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? widget.world.visuals.primaryColor.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBossLevel
                ? Colors.red.withValues(alpha: 0.8)
                : isUnlocked
                    ? widget.world.visuals.primaryColor.withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.3),
            width: isBossLevel ? 3 : 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: widget.world.visuals.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Level number
            Center(
              child: Text(
                '$levelNumber',
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.white38,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Boss indicator
            if (isBossLevel)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.shield,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            
            // Lock icon
            if (!isUnlocked)
              Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white38,
                  size: 30,
                ),
              ),
            
            // Stars
            if (isCompleted && stars > 0)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                      size: 14,
                    );
                  }),
                ),
              ),
            
            // Difficulty indicator
            if (isUnlocked)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(level.difficulty),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWorldProgress() {
    final completionPercentage = widget.world.completionPercentage;
    
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: completionPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.world.visuals.primaryColor,
                          widget.world.visuals.accentColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: widget.world.visuals.accentColor,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                // Milestone markers
                ...List.generate(4, (i) {
                  final position = (i + 1) * 0.25;
                  return Positioned(
                    left: MediaQuery.of(context).size.width * position - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.black54,
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 12),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${(completionPercentage * 100).toInt()}% COMPLETE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                '${widget.world.levelsCompleted}/20 LEVELS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              if (widget.world.bossInfo != null)
                Text(
                  widget.world.bossDefeated ? 'BOSS DEFEATED' : 'BOSS AWAITS',
                  style: TextStyle(
                    color: widget.world.bossDefeated ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  LevelDifficulty _getLevelDifficulty(int levelNumber) {
    if (levelNumber <= 5) return LevelDifficulty.easy;
    if (levelNumber <= 10) return LevelDifficulty.medium;
    if (levelNumber <= 15) return LevelDifficulty.hard;
    if (levelNumber <= 19) return LevelDifficulty.expert;
    return LevelDifficulty.insane; // Boss level
  }
  
  Color _getDifficultyColor(LevelDifficulty difficulty) {
    switch (difficulty) {
      case LevelDifficulty.tutorial:
      case LevelDifficulty.easy:
        return Colors.green;
      case LevelDifficulty.medium:
        return Colors.yellow;
      case LevelDifficulty.hard:
        return Colors.orange;
      case LevelDifficulty.expert:
        return Colors.red;
      case LevelDifficulty.insane:
        return Colors.purple;
    }
  }
  
  void _navigateToLevel(Level level) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return MainGameScreen(
            level: level,
            showTutorial: level.isTutorial,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
  
  void _showLockedLevelDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.red.withValues(alpha: 0.5),
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
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'LEVEL LOCKED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Complete previous levels to unlock',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
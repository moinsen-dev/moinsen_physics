import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../../tutorial/presentation/controllers/tutorial_controller.dart';
import '../../../tutorial/presentation/widgets/tutorial_overlay.dart';
import '../../../tutorial/domain/entities/tutorial_step.dart';
import '../../../polish/haptic_manager.dart';
import '../../../polish/juice_effects.dart';
import '../../../polish/screen_shake.dart';
import '../../../polish/slow_motion_controller.dart';
import '../../../levels/domain/entities/level.dart';
import '../components/gravity_lab_game.dart';
import '../components/game_ui.dart';
import '../widgets/undo_redo_controls.dart';

/// Main game screen that integrates all systems
class MainGameScreen extends StatefulWidget {
  final Level level;
  final bool showTutorial;
  
  const MainGameScreen({
    super.key,
    required this.level,
    this.showTutorial = false,
  });

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen>
    with TickerProviderStateMixin {
  late final GravityLabGame game;
  late final ScreenShakeController shakeController;
  late final SlowMotionController slowMotionController;
  late final TutorialController tutorialController;
  late final JuiceEffects juiceEffects;
  
  // Game state
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isVictory = false;
  int _stars = 0;
  int _moves = 0;
  double _timeElapsed = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    shakeController = ScreenShakeController();
    slowMotionController = SlowMotionController();
    tutorialController = TutorialController(levelId: widget.level.id);
    juiceEffects = JuiceEffects();
    
    // Initialize game
    game = GravityLabGame(
      level: widget.level,
      onVictory: _onVictory,
      onFailure: _onFailure,
      onMove: _onMove,
      onTimeUpdate: _onTimeUpdate,
      onCollision: _onCollision,
      onGravitySwitch: _onGravitySwitch,
    );
    
    // Start tutorial if needed
    if (widget.showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTutorial();
      });
    }
  }
  
  @override
  void dispose() {
    game.detach();
    super.dispose();
  }
  
  void _startTutorial() {
    // Tutorial is auto-loaded in controller constructor
    // Just disable game input until tutorial advances
    game.disableInput();
  }
  
  void _onVictory(int stars, int moves, double time) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isVictory = true;
        _isGameOver = true;
        _stars = stars;
      });
    });
    
    // Victory effects
    _triggerVictoryEffects(stars);
    
    // Show victory screen after effects
    Future.delayed(const Duration(seconds: 2), () {
      _showVictoryDialog();
    });
  }
  
  void _onFailure() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isGameOver = true;
        _isVictory = false;
      });
    });
    
    // Failure effects
    HapticManager.failure();
    shakeController.shake(
      intensity: 20,
      decay: 0.9,
      pattern: ShakePattern.horizontal,
    );
    
    // Show failure screen
    Future.delayed(const Duration(milliseconds: 500), () {
      _showFailureDialog();
    });
  }
  
  void _onMove() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _moves++;
        });
      }
    });

    // Move feedback
    HapticManager.lightImpact();
  }

  void _onTimeUpdate(double time) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _timeElapsed = time;
        });
      }
    });
  }
  
  void _onCollision(Vector2 position, double force) {
    // Add collision effects
    game.world.add(
      juiceEffects.collision(
        position: position,
        force: force,
        color1: Colors.orange,
        color2: Colors.yellow,
      ),
    );
    
    // Screen shake for big impacts
    if (force > 0.5) {
      shakeController.shake(
        intensity: force * 15,
        decay: 0.9,
      );
    }
    
    // Slow motion for massive impacts
    if (force > 0.8) {
      slowMotionController.collision(force: force);
    }
  }
  
  void _onGravitySwitch(Vector2 position, Vector2 oldGravity, Vector2 newGravity) {
    // Add gravity switch effects
    game.world.add(
      juiceEffects.gravitySwitch(
        position: position,
        oldGravity: oldGravity,
        newGravity: newGravity,
      ),
    );
    
    // Screen shake
    shakeController.shake(
      intensity: 12,
      pattern: ShakePattern.circular,
    );
    
    // Brief slow motion for dramatic effect
    slowMotionController.start(
      scale: 0.5,
      duration: 0.2,
      curve: SlowMotionCurve.quick,
    );
  }
  
  void _triggerVictoryEffects(int stars) {
    // Victory celebration
    game.world.add(
      juiceEffects.victoryCelebration(
        position: game.size / 2,
        stars: stars,
      ),
    );
    
    // Epic slow motion
    slowMotionController.victory();
    
    // Victory screen shake
    shakeController.shake(
      intensity: 25,
      pattern: ShakePattern.circular,
      decay: 0.98,
    );
  }
  
  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    game.pauseEngine();
    slowMotionController.stopInstant();
    HapticManager.buttonPress();
  }
  
  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    game.resumeEngine();
    HapticManager.buttonPress();
  }
  
  void _restartLevel() {
    setState(() {
      _moves = 0;
      _timeElapsed = 0;
      _isGameOver = false;
      _isVictory = false;
      _stars = 0;
    });
    
    game.resetLevel();
    shakeController.stop();
    slowMotionController.stopInstant();
    
    HapticManager.buttonPress();
  }
  
  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        stars: _stars,
        moves: _moves,
        time: _timeElapsed,
        onNextLevel: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Go back to level select
        },
        onRestart: () {
          Navigator.of(context).pop();
          _restartLevel();
        },
      ),
    );
  }
  
  void _showFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FailureDialog(
        onRestart: () {
          Navigator.of(context).pop();
          _restartLevel();
        },
        onQuit: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
  
  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => PauseDialog(
        onResume: () {
          Navigator.of(context).pop();
          _resumeGame();
        },
        onRestart: () {
          Navigator.of(context).pop();
          _restartLevel();
        },
        onQuit: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isPaused || _isGameOver,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_isPaused && !_isGameOver) {
          _pauseGame();
          _showPauseDialog();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: UndoRedoGestureDetector(
          onSwipeLeft: () {
            if (game.canUndo && !_isGameOver && !_isPaused) {
              game.undo();
              setState(() {});
            }
          },
          onSwipeRight: () {
            if (game.canRedo && !_isGameOver && !_isPaused) {
              game.redo();
              setState(() {});
            }
          },
          child: Stack(
            children: [
            // Game with screen shake
            ScreenShakeWidget(
              controller: shakeController,
              child: GameWidget(game: game),
            ),
            
            // Slow motion overlay
            SlowMotionOverlay(
              controller: slowMotionController,
              color: Colors.purple,
              showVignette: true,
              showMotionBlur: true,
            ),
            
            // Game UI
            GameUI(
              level: widget.level,
              moves: _moves,
              time: _timeElapsed,
              stars: _stars,
              isPaused: _isPaused,
              isGameOver: _isGameOver,
              isVictory: _isVictory,
              onPause: _pauseGame,
              onRestart: _restartLevel,
            ),
            
            // Undo/Redo controls
            if (!_isGameOver && !_isPaused)
              Positioned(
                bottom: 24,
                right: 16,
                child: UndoRedoControls(
                  canUndo: game.canUndo,
                  canRedo: game.canRedo,
                  onUndo: () {
                    game.undo();
                    setState(() {});
                  },
                  onRedo: () {
                    game.redo();
                    setState(() {});
                  },
                ),
              ),
            
            // Tutorial overlay
            if (widget.showTutorial && tutorialController.isActive)
              TutorialOverlay(
                currentStep: tutorialController.currentStep ?? TutorialStep(
                  id: 'empty',
                  title: '',
                  description: '',
                  action: TutorialAction.waitForAction,
                ),
                progress: tutorialController.progress,
                onNext: () {
                  tutorialController.nextStep();
                  if (tutorialController.isCompleted) {
                    game.enableInput();
                  }
                  setState(() {});
                },
                onSkip: () {
                  tutorialController.skipTutorial();
                  game.enableInput();
                  setState(() {});
                },
              ),
            
            // Pause overlay
            if (_isPaused)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: Text(
                    'PAUSED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
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
}

/// Victory dialog with juice effects
class VictoryDialog extends StatefulWidget {
  final int stars;
  final int moves;
  final double time;
  final VoidCallback onNextLevel;
  final VoidCallback onRestart;
  
  const VictoryDialog({
    super.key,
    required this.stars,
    required this.moves,
    required this.time,
    required this.onNextLevel,
    required this.onRestart,
  });
  
  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _scaleController.forward();
    _rotationController.repeat();
    
    // Haptic celebration
    HapticManager.victoryCelebration();
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Victory text with rotation
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 0.1,
                        child: const Text(
                          '🎉 VICTORY! 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stars display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isEarned = index < widget.stars;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200 + index * 100),
                        curve: Curves.elasticOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          isEarned ? Icons.star : Icons.star_border,
                          color: isEarned ? Colors.yellow : Colors.white54,
                          size: 40,
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('Moves', '${widget.moves}'),
                        const SizedBox(height: 8),
                        _buildStatRow('Time', _formatTime(widget.time)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onRestart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('RESTART'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onNextLevel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'NEXT LEVEL',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// Failure dialog
class FailureDialog extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onQuit;
  
  const FailureDialog({
    super.key,
    required this.onRestart,
    required this.onQuit,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F2937),
              Color(0xFF374151),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💥 GAME OVER 💥',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Don\'t give up! Try again!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onQuit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('QUIT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'TRY AGAIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pause dialog
class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;
  
  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⏸️ PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onResume,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'RESUME',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'RESTART',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onQuit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'QUIT TO MENU',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../levels/domain/entities/level.dart';
import '../../../polish/haptic_manager.dart';

/// Game UI overlay showing stats and controls
class GameUI extends StatelessWidget {
  final Level level;
  final int moves;
  final double time;
  final int stars;
  final bool isPaused;
  final bool isGameOver;
  final bool isVictory;
  final VoidCallback onPause;
  final VoidCallback onRestart;
  
  const GameUI({
    super.key,
    required this.level,
    required this.moves,
    required this.time,
    required this.stars,
    required this.isPaused,
    required this.isGameOver,
    required this.isVictory,
    required this.onPause,
    required this.onRestart,
  });
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Top bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Level info
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      level.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Stats
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(time),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.touch_app, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$moves',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Restart button
                _ControlButton(
                  icon: Icons.refresh,
                  onPressed: () {
                    HapticManager.buttonPress();
                    onRestart();
                  },
                ),
                const SizedBox(width: 8),

                // Pause button
                if (!isGameOver)
                  _ControlButton(
                    icon: isPaused ? Icons.play_arrow : Icons.pause,
                    onPressed: () {
                      HapticManager.buttonPress();
                      onPause();
                    },
                  ),
              ],
            ),
          ),
          
          // Stars display (only show when victory)
          if (isVictory)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: index < stars ? 1.0 : 0.3,
                    ),
                    duration: Duration(milliseconds: 500 + index * 200),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.star,
                          color: index < stars
                              ? Colors.yellow
                              : Colors.white.withValues(alpha: 0.3),
                          size: 60,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          
          // Gravity indicator
          Positioned(
            bottom: 24,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.cyan.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.arrow_downward,
                color: Colors.cyan,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// Reusable control button
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  
  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
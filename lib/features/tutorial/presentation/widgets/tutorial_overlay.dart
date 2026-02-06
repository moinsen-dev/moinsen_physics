import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart' show Vector2;
import '../../domain/entities/tutorial_step.dart';
import 'ghost_hand.dart';
import 'hint_bubble.dart';

/// Overlay widget that displays tutorial elements on top of the game
class TutorialOverlay extends StatefulWidget {
  final TutorialStep? currentStep;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final double progress;
  
  const TutorialOverlay({
    super.key,
    required this.currentStep,
    required this.onSkip,
    required this.onNext,
    required this.progress,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }
  
  @override
  void didUpdateWidget(TutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      _fadeController.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.currentStep == null) {
      return const SizedBox.shrink();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Darkened overlay with cutout
          if (widget.currentStep!.highlightPosition != null)
            _buildHighlightOverlay(),
          
          // Tutorial content
          _buildTutorialContent(),
          
          // Skip button
          if (widget.currentStep!.canSkip)
            _buildSkipButton(),
          
          // Progress indicator
          _buildProgressIndicator(),
        ],
      ),
    );
  }
  
  Widget _buildHighlightOverlay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: HighlightPainter(
            highlightCenter: widget.currentStep!.highlightPosition!,
            highlightRadius: (widget.currentStep!.highlightRadius ?? 50) * 
                _pulseAnimation.value,
          ),
        );
      },
    );
  }
  
  Widget _buildTutorialContent() {
    final step = widget.currentStep!;
    
    switch (step.action) {
      case TutorialAction.showInfo:
        return Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: HintBubble(
            title: step.title,
            description: step.description,
            onNext: widget.onNext,
          ),
        );
        
      case TutorialAction.showGhostHand:
        return GhostHandWidget(
          animation: GhostHandAnimation(
            startPosition: step.highlightPosition ?? Vector2.zero(),
            endPosition: step.highlightPosition ?? Vector2.zero(),
            duration: const Duration(seconds: 2),
          ),
        );
        
      case TutorialAction.showArrow:
        return _buildArrow();
        
      default:
        return _buildDefaultContent();
    }
  }
  
  Widget _buildArrow() {
    return Positioned(
      top: 200,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Icon(
                Icons.arrow_downward,
                size: 64,
                color: Colors.yellow.withOpacity(0.8),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildDefaultContent() {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.cyan.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.currentStep!.title,
              style: const TextStyle(
                color: Colors.cyan,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.currentStep!.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'GOT IT!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkipButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          widget.onSkip();
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.black54,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        child: const Text(
          'Skip Tutorial',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Positioned(
      top: 50,
      left: 20,
      child: Container(
        width: 120,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widget.progress,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for highlight overlay with cutout
class HighlightPainter extends CustomPainter {
  final Vector2 highlightCenter;
  final double highlightRadius;
  
  HighlightPainter({
    required this.highlightCenter,
    required this.highlightRadius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    // Create path with hole
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(
        center: Offset(highlightCenter.x, highlightCenter.y),
        radius: highlightRadius,
      ))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);
    
    // Draw glowing edge
    final edgePaint = Paint()
      ..color = Colors.cyan.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
    
    canvas.drawCircle(
      Offset(highlightCenter.x, highlightCenter.y),
      highlightRadius,
      edgePaint,
    );
  }
  
  @override
  bool shouldRepaint(HighlightPainter oldDelegate) {
    return oldDelegate.highlightCenter != highlightCenter ||
           oldDelegate.highlightRadius != highlightRadius;
  }
}
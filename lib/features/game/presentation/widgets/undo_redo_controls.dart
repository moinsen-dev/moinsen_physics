import 'package:flutter/material.dart';
import '../../../polish/haptic_manager.dart';

/// Undo/Redo control widget with visual feedback
class UndoRedoControls extends StatefulWidget {
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool showLabels;
  
  const UndoRedoControls({
    super.key,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    this.showLabels = false,
  });
  
  @override
  State<UndoRedoControls> createState() => _UndoRedoControlsState();
}

class _UndoRedoControlsState extends State<UndoRedoControls>
    with TickerProviderStateMixin {
  late AnimationController _undoAnimController;
  late AnimationController _redoAnimController;
  late Animation<double> _undoScaleAnimation;
  late Animation<double> _redoScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _undoAnimController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _redoAnimController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _undoScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _undoAnimController,
      curve: Curves.easeInOut,
    ));
    
    _redoScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _redoAnimController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _undoAnimController.dispose();
    _redoAnimController.dispose();
    super.dispose();
  }
  
  void _handleUndo() {
    if (!widget.canUndo) return;
    
    // Animate button
    _undoAnimController.forward().then((_) {
      _undoAnimController.reverse();
    });
    
    // Haptic feedback
    HapticManager.mediumImpact();
    
    // Execute undo
    widget.onUndo();
  }
  
  void _handleRedo() {
    if (!widget.canRedo) return;
    
    // Animate button
    _redoAnimController.forward().then((_) {
      _redoAnimController.reverse();
    });
    
    // Haptic feedback
    HapticManager.mediumImpact();
    
    // Execute redo
    widget.onRedo();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Undo button
          AnimatedBuilder(
            animation: _undoScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _undoScaleAnimation.value,
                child: _UndoRedoButton(
                  icon: Icons.undo,
                  enabled: widget.canUndo,
                  onPressed: _handleUndo,
                  label: widget.showLabels ? 'Undo' : null,
                ),
              );
            },
          ),
          
          const SizedBox(width: 12),
          
          // Redo button
          AnimatedBuilder(
            animation: _redoScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _redoScaleAnimation.value,
                child: _UndoRedoButton(
                  icon: Icons.redo,
                  enabled: widget.canRedo,
                  onPressed: _handleRedo,
                  label: widget.showLabels ? 'Redo' : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual undo/redo button
class _UndoRedoButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final String? label;
  
  const _UndoRedoButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? Colors.white
        : Colors.white.withValues(alpha: 0.3);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              if (label != null) ...[
                const SizedBox(width: 4),
                Text(
                  label!,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Gesture detector for swipe-based undo/redo
class UndoRedoGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback onSwipeLeft; // Undo
  final VoidCallback onSwipeRight; // Redo
  final double sensitivity;
  
  const UndoRedoGestureDetector({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.sensitivity = 50.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        
        if (velocity.abs() < sensitivity) return;
        
        if (velocity < 0) {
          // Swipe left - Undo
          HapticManager.lightImpact();
          onSwipeLeft();
        } else {
          // Swipe right - Redo
          HapticManager.lightImpact();
          onSwipeRight();
        }
      },
      child: child,
    );
  }
}

/// Visual indicator for undo/redo action
class UndoRedoIndicator extends StatefulWidget {
  final bool isUndo;
  final VoidCallback onComplete;
  
  const UndoRedoIndicator({
    super.key,
    required this.isUndo,
    required this.onComplete,
  });
  
  @override
  State<UndoRedoIndicator> createState() => _UndoRedoIndicatorState();
}

class _UndoRedoIndicatorState extends State<UndoRedoIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      reverseCurve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.isUndo ? 0.5 : -0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        widget.onComplete();
      });
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isUndo ? Icons.undo : Icons.redo,
                        color: Colors.cyan,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.isUndo ? 'UNDO' : 'REDO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
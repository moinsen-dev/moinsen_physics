import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import '../../domain/entities/tutorial_step.dart';

/// Animated ghost hand that shows players how to interact
class GhostHandWidget extends StatefulWidget {
  final GhostHandAnimation animation;
  final VoidCallback? onAnimationComplete;
  
  const GhostHandWidget({
    super.key,
    required this.animation,
    this.onAnimationComplete,
  });

  @override
  State<GhostHandWidget> createState() => _GhostHandWidgetState();
}

class _GhostHandWidgetState extends State<GhostHandWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animation.duration,
      vsync: this,
    );
    
    _positionAnimation = Tween<Offset>(
      begin: Offset(
        widget.animation.startPosition.x,
        widget.animation.startPosition.y,
      ),
      end: Offset(
        widget.animation.endPosition.x,
        widget.animation.endPosition.y,
      ),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animation.curve,
    ));
    
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.8),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.8),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.0),
        weight: 20,
      ),
    ]).animate(_controller);
    
    // Scale animation for tap gesture
    if (widget.animation.gesture == GhostHandGesture.tap) {
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.0),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.8),
          weight: 10,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.8, end: 1.2),
          weight: 10,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0),
          weight: 40,
        ),
      ]).animate(_controller);
    } else {
      _scaleAnimation = AlwaysStoppedAnimation(1.0);
    }
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onAnimationComplete != null) {
          widget.onAnimationComplete!();
        } else {
          _controller.repeat();
        }
      }
    });
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx - 30,
          top: _positionAnimation.value.dy - 30,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: _buildHandIcon(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHandIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getIconForGesture(),
          color: Colors.black87,
          size: 32,
        ),
      ),
    );
  }
  
  IconData _getIconForGesture() {
    switch (widget.animation.gesture) {
      case GhostHandGesture.tap:
        return Icons.touch_app;
      case GhostHandGesture.drag:
        return Icons.pan_tool;
      case GhostHandGesture.swipe:
        return Icons.swipe;
      case GhostHandGesture.pinch:
        return Icons.pinch;
      case GhostHandGesture.hold:
        return Icons.radio_button_checked;
    }
  }
}

/// Ripple effect for tap gestures
class TapRipple extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback? onComplete;
  
  const TapRipple({
    super.key,
    required this.position,
    this.color = Colors.cyan,
    this.onComplete,
  });

  @override
  State<TapRipple> createState() => _TapRippleState();
}

class _TapRippleState extends State<TapRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color,
                    width: 3,
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
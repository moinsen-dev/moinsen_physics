import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Speech bubble widget for tutorial hints and tips
class HintBubble extends StatefulWidget {
  final String title;
  final String description;
  final VoidCallback? onNext;
  final VoidCallback? onDismiss;
  final HintBubblePosition position;
  final Color backgroundColor;
  final Color textColor;
  
  const HintBubble({
    super.key,
    required this.title,
    required this.description,
    this.onNext,
    this.onDismiss,
    this.position = HintBubblePosition.bottom,
    this.backgroundColor = Colors.black87,
    this.textColor = Colors.white,
  });

  @override
  State<HintBubble> createState() => _HintBubbleState();
}

class _HintBubbleState extends State<HintBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildBubble(),
          ),
        );
      },
    );
  }
  
  Widget _buildBubble() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 320,
        minWidth: 200,
      ),
      child: Stack(
        alignment: _getStackAlignment(),
        children: [
          // Main bubble
          Container(
            margin: _getBubbleMargin(),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.cyan.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  widget.description,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                // Actions
                if (widget.onNext != null || widget.onDismiss != null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.onDismiss != null)
                            TextButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                widget.onDismiss!();
                              },
                              child: Text(
                                'DISMISS',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (widget.onNext != null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                widget.onNext!();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'NEXT',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Tail/Arrow
          Positioned(
            child: CustomPaint(
              size: const Size(20, 10),
              painter: BubbleTailPainter(
                color: widget.backgroundColor,
                borderColor: Colors.cyan.withValues(alpha: 0.5),
                position: widget.position,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  AlignmentGeometry _getStackAlignment() {
    switch (widget.position) {
      case HintBubblePosition.top:
        return Alignment.topCenter;
      case HintBubblePosition.bottom:
        return Alignment.bottomCenter;
      case HintBubblePosition.left:
        return Alignment.centerLeft;
      case HintBubblePosition.right:
        return Alignment.centerRight;
    }
  }
  
  EdgeInsets _getBubbleMargin() {
    switch (widget.position) {
      case HintBubblePosition.top:
        return const EdgeInsets.only(bottom: 10);
      case HintBubblePosition.bottom:
        return const EdgeInsets.only(top: 10);
      case HintBubblePosition.left:
        return const EdgeInsets.only(right: 10);
      case HintBubblePosition.right:
        return const EdgeInsets.only(left: 10);
    }
  }
}

enum HintBubblePosition {
  top,
  bottom,
  left,
  right,
}

/// Custom painter for bubble tail
class BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final HintBubblePosition position;
  
  BubbleTailPainter({
    required this.color,
    required this.borderColor,
    required this.position,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    Path path;
    
    switch (position) {
      case HintBubblePosition.top:
        path = Path()
          ..moveTo(0, size.height)
          ..lineTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..close();
        break;
      case HintBubblePosition.bottom:
        path = Path()
          ..moveTo(0, 0)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width, 0)
          ..close();
        break;
      case HintBubblePosition.left:
        path = Path()
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width, size.height)
          ..close();
        break;
      case HintBubblePosition.right:
        path = Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(0, size.height)
          ..close();
        break;
    }
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }
  
  @override
  bool shouldRepaint(BubbleTailPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.position != position;
  }
}
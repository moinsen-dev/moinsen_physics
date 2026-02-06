import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../levels/presentation/screens/world_selection_screen.dart';

/// Epic main menu for Gravity Lab 2.0
class QuantumMainMenu extends StatefulWidget {
  const QuantumMainMenu({super.key});

  @override
  State<QuantumMainMenu> createState() => _QuantumMainMenuState();
}

class _QuantumMainMenuState extends State<QuantumMainMenu>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _titleController;
  late AnimationController _menuController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  
  late Animation<double> _titleScale;
  late Animation<double> _titleGlow;
  late Animation<double> _menuSlide;
  
  @override
  void initState() {
    super.initState();
    
    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Title animations
    _titleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _titleScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    ));
    
    _titleGlow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));
    
    // Menu animations
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _menuSlide = Tween<double>(
      begin: 300.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutCubic,
    ));
    
    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Pulse animation for PLAY button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Start animations
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _menuController.forward();
    });
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _titleController.dispose();
    _menuController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
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
                painter: QuantumBackgroundPainter(
                  animation: _backgroundController.value,
                ),
              );
            },
          ),
          
          // Particle effects
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: ParticleFieldPainter(
                  animation: _particleController.value,
                ),
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  AnimatedBuilder(
                    animation: _titleController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _titleScale.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.cyan,
                                Colors.purple,
                                Colors.cyan,
                              ],
                              stops: [
                                0.0,
                                0.5 + 0.5 * sin(_backgroundController.value * 2 * pi),
                                1.0,
                              ],
                            ).createShader(bounds);
                          },
                          child: Column(
                            children: [
                              Text(
                                'GRAVITY LAB',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 8,
                                  shadows: [
                                    Shadow(
                                      color: Colors.cyan.withValues(alpha: _titleGlow.value),
                                      blurRadius: 30,
                                    ),
                                    Shadow(
                                      color: Colors.purple.withValues(alpha: _titleGlow.value * 0.5),
                                      blurRadius: 50,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '2.0 QUANTUM EDITION',
                                style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 4,
                                  color: Colors.white.withValues(alpha: _titleGlow.value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Menu items
                  AnimatedBuilder(
                    animation: _menuController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _menuSlide.value),
                        child: Column(
                          children: [
                            _buildPlayButton(context),
                            const SizedBox(height: 16),
                            _buildDisabledButton(
                              'COMING SOON',
                              Icons.lock_outline,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Version info
                  Text(
                    'Revolutionary Physics Gaming Experience',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Floating particles
          ...List.generate(20, (index) {
            return AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                final progress = (_backgroundController.value + index / 20) % 1.0;
                final size = MediaQuery.of(context).size;
                
                return Positioned(
                  left: size.width * (index / 20),
                  bottom: size.height * progress,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 1 - progress),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.5 * (1 - progress)),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildPlayButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;
        final scale = 1.0 + pulse * 0.04;
        final glowAlpha = 0.3 + pulse * 0.4;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 280,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withValues(alpha: 0.4 + pulse * 0.2),
                  Colors.green.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.6 + pulse * 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withValues(alpha: glowAlpha),
                  blurRadius: 20 + pulse * 15,
                  spreadRadius: 2 + pulse * 4,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _navigateToGame(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow, color: Colors.greenAccent, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.greenAccent, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisabledButton(String text, IconData icon) {
    return Opacity(
      opacity: 0.35,
      child: Container(
        width: 280,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Icon(icon, color: Colors.white54, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const WorldSelectionScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
  
}

/// Quantum background painter
class QuantumBackgroundPainter extends CustomPainter {
  final double animation;
  
  QuantumBackgroundPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;
    
    // Draw multiple moving gradients
    for (int i = 0; i < 3; i++) {
      final center = Offset(
        size.width * (0.5 + 0.3 * sin(animation * 2 * pi + i * pi / 3)),
        size.height * (0.5 + 0.3 * cos(animation * 2 * pi + i * pi / 3)),
      );
      
      paint.shader = RadialGradient(
        center: Alignment(
          (center.dx - size.width / 2) / (size.width / 2),
          (center.dy - size.height / 2) / (size.height / 2),
        ),
        radius: 1.5,
        colors: [
          Colors.purple.withValues(alpha: 0.2),
          Colors.cyan.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(QuantumBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Particle field painter
class ParticleFieldPainter extends CustomPainter {
  final double animation;
  final Random random = Random(42);
  
  ParticleFieldPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..blendMode = BlendMode.plus;
    
    // Draw particle field
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final phase = random.nextDouble() * 2 * pi;
      
      final opacity = 0.5 + 0.5 * sin(animation * 2 * pi + phase);
      final radius = 1 + sin(animation * 4 * pi + phase);
      
      paint.color = Colors.cyan.withValues(alpha: opacity * 0.5);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(ParticleFieldPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
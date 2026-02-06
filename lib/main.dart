import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:math';
import 'features/menu/presentation/screens/quantum_main_menu.dart';

/// The entry point for Gravity Lab 2.0 - The Quantum Revolution
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up the game environment
  await _initializeGame();
  
  runApp(const ProviderScope(child: GravityLab2App()));
}

/// Initialize game systems
Future<void> _initializeGame() async {
  // Enable immersive mode for epic experience
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  
  // Lock to portrait - game world is 400x600 (portrait ratio)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set dark status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  
  // TODO: Preload essential game assets
  // await Flame.images.loadAll([...]);
  
  // TODO: Initialize audio engine
  // TODO: Set up crash reporting
}

/// Gravity Lab 2.0 - Revolutionary Physics Gaming
class GravityLab2App extends ConsumerWidget {
  const GravityLab2App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Gravity Lab 2.0',
      debugShowCheckedModeBanner: false,
      
      // Quantum-inspired dark theme
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Orbitron',
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyan,
          secondary: Colors.purple,
          tertiary: Colors.yellow,
        ),
      ),
      
      // Localization support for global domination
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      
      // Start with epic splash screen
      home: const SplashScreen(),
    );
  }
}

/// Epic splash screen with quantum animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _particleRadius;
  
  @override
  void initState() {
    super.initState();
    
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5),
    ));
    
    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _particleRadius = Tween<double>(
      begin: 0.0,
      end: 300.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _logoController.forward();
    
    // Navigate to main menu after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                const QuantumMainMenu(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated particle field background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: QuantumParticlePainter(
                  radius: _particleRadius.value,
                  opacity: 1.0 - (_particleRadius.value / 300),
                ),
              );
            },
          ),
          
          // Logo and text
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScale.value,
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Quantum atom logo
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyan.withValues(alpha: 0.8),
                                Colors.purple.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withValues(alpha: 0.5),
                                blurRadius: 50,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Nucleus
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              // Electron orbits
                              ...List.generate(3, (index) {
                                return Transform.rotate(
                                  angle: (index * 60) * pi / 180,
                                  child: Container(
                                    width: 120,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      border: Border.all(
                                        color: Colors.cyan.withValues(alpha: 0.5),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [Colors.cyan, Colors.purple],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'GRAVITY LAB',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '2.0 QUANTUM EDITION',
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 4,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Loading indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                      strokeWidth: 2,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quantum particle painter for splash screen
class QuantumParticlePainter extends CustomPainter {
  final double radius;
  final double opacity;
  
  QuantumParticlePainter({
    required this.radius,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;
    
    // Draw expanding quantum field
    paint.shader = RadialGradient(
      colors: [
        Colors.cyan.withValues(alpha: opacity * 0.3),
        Colors.purple.withValues(alpha: opacity * 0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, paint);
    
    // Draw particle ring
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = Colors.cyan.withValues(alpha: opacity * 0.5);
    
    canvas.drawCircle(center, radius * 0.8, paint);
  }
  
  @override
  bool shouldRepaint(QuantumParticlePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.opacity != opacity;
  }
}

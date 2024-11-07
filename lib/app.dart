import 'package:flutter/material.dart';

import '_index.dart';

class MoinsenPhysicsApp extends StatelessWidget {
  const MoinsenPhysicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppSplashScreen(),
    );
  }
}

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  AppSplashScreenState createState() => AppSplashScreenState();
}

class AppSplashScreenState extends State<AppSplashScreen> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Make sure Stack fills the screen
        children: [
          // Newton Cradle layer
          Positioned.fill(
            child: IgnorePointer(
              ignoring:
                  _showSplash, // Only ignore gestures when splash is showing
              child: const NewtonCradlePlainDart(
                controls: SimulationControls.defaultControls,
              ),
            ),
          ),
          // Splash screen layer
          if (_showSplash) const SplashScreen(),
        ],
      ),
    );
  }
}

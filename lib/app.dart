import 'package:flutter/material.dart';

import '_index.dart';

class MoinsenPhysicsApp extends StatelessWidget {
  const MoinsenPhysicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    debugPrint('Screen size: ${MediaQuery.of(context).size}');

    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Make sure Stack fills the screen
        children: [
          // Newton Cradle layer
          Positioned.fill(
            child: IgnorePointer(
              ignoring:
                  _showSplash, // Only ignore gestures when splash is showing
              child: const NewtonCradleWidget(),
            ),
          ),
          // Splash screen layer
          if (_showSplash)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/splash.png',
                        width: screenWidth * 0.8,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Moinsen Physics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

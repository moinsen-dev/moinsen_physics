import 'package:flutter/material.dart';

/// Quantum-inspired theme for Gravity Lab 2.0
class QuantumTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.cyan,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Orbitron', // Futuristic font
    
    colorScheme: const ColorScheme.dark(
      primary: Colors.cyan,
      secondary: Colors.purple,
      tertiary: Colors.yellow,
      error: Colors.red,
      surface: Color(0xFF0A0A0A),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: Colors.white70,
    ),
    
    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.cyan,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      iconTheme: IconThemeData(color: Colors.cyan),
    ),
    
    // Text theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.cyan,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 3,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      bodyLarge: TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.white60,
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
    
    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: Colors.cyan.withValues(alpha: 0.5),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyan,
        side: BorderSide(color: Colors.cyan, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    ),
    
    // Icon theme
    iconTheme: const IconThemeData(
      color: Colors.cyan,
      size: 24,
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      color: Colors.black.withValues(alpha: 0.8),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.cyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    ),
    
    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.purple.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
    ),
    
    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.cyan,
      inactiveTrackColor: Colors.cyan.withValues(alpha: 0.3),
      thumbColor: Colors.cyan,
      overlayColor: Colors.cyan.withValues(alpha: 0.3),
      trackHeight: 4,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
    ),
    
    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? Colors.cyan : Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) 
            ? Colors.cyan.withValues(alpha: 0.5) 
            : Colors.grey.withValues(alpha: 0.3);
      }),
    ),
    
    // Divider theme
    dividerTheme: DividerThemeData(
      color: Colors.cyan.withValues(alpha: 0.3),
      thickness: 1,
    ),
  );
  
  // Quantum gradient colors
  static const List<Color> quantumGradient = [
    Colors.cyan,
    Colors.purple,
    Colors.deepPurple,
  ];
  
  static const List<Color> energyGradient = [
    Colors.yellow,
    Colors.orange,
    Colors.red,
  ];
  
  static const List<Color> spaceGradient = [
    Color(0xFF000428),
    Color(0xFF004e92),
  ];
  
  // Special effect colors
  static Color glowColor = Colors.cyan.withValues(alpha: 0.5);
  static Color pulseColor = Colors.purple.withValues(alpha: 0.3);
  static Color explosionColor = Colors.orange;
  
  // Utility methods for consistent styling
  static BoxDecoration quantumContainer({
    double borderRadius = 20,
    double glowRadius = 20,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.black.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.cyan.withValues(alpha: 0.5),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor ?? Colors.cyan.withValues(alpha: 0.3),
          blurRadius: glowRadius,
          spreadRadius: 2,
        ),
      ],
    );
  }
  
  static Gradient quantumGradientShader({
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors ?? quantumGradient,
      begin: begin,
      end: end,
    );
  }
  
  static TextStyle quantumTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.bold,
    double letterSpacing = 2,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color ?? Colors.white,
      shadows: [
        Shadow(
          color: (color ?? Colors.cyan).withValues(alpha: 0.5),
          blurRadius: 10,
        ),
      ],
    );
  }
}
# Gravity Lab - Visual Design System
## Flutter Implementation Guide

**Version:** 1.0  
**Date:** May 2024  
**Purpose:** Complete visual design system for Flutter implementation

---

## 1. Color System

### Primary Palette
```dart
class GravityLabColors {
  // Main Brand Colors
  static const primaryBlue = Color(0xFF00A8FF);
  static const secondaryPurple = Color(0xFF8B5CF6);
  static const accentYellow = Color(0xFFFFD93D);
  
  // UI Colors
  static const background = Color(0xFF0A0E27);
  static const surface = Color(0xFF1A1F3A);
  static const surfaceLight = Color(0xFF2A2F4A);
  
  // Semantic Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB8BCC8);
  static const textDisabled = Color(0xFF6B7280);
  
  // Physics Object Colors
  static const ballGreen = Color(0xFF4ADE80);
  static const cubeBlue = Color(0xFF60A5FA);
  static const balloonPink = Color(0xFFF472B6);
  static const blobPurple = Color(0xFFC084FC);
  static const ghostWhite = Color(0xFFE5E7EB);
  static const energyYellow = Color(0xFFFDE047);
  static const iceCyan = Color(0xFF67E8F9);
  static const magnetRed = Color(0xFFF87171);
}
```

### Gradient Definitions
```dart
class GradientStyles {
  static const blueGlow = LinearGradient(
    colors: [Color(0xFF00A8FF), Color(0xFF0080CC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const purpleGlow = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  );
  
  static const spaceBackground = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
    stops: [0.0, 0.5, 1.0],
  );
}
```

---

## 2. Typography System

### Font Setup (pubspec.yaml)
```yaml
fonts:
  - family: Orbitron
    fonts:
      - asset: assets/fonts/Orbitron-Regular.ttf
      - asset: assets/fonts/Orbitron-Bold.ttf
        weight: 700
  - family: Roboto
    fonts:
      - asset: assets/fonts/Roboto-Regular.ttf
      - asset: assets/fonts/Roboto-Medium.ttf
        weight: 500
```

### Text Styles
```dart
class GravityLabTextStyles {
  static const displayLarge = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 56,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
  );
  
  static const displayMedium = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 45,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const headlineLarge = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const headlineMedium = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static const bodyLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );
  
  static const bodyMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const labelLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
}
```

---

## 3. Component Library

### Primary Button
```dart
class GravityLabButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: GradientStyles.blueGlow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: GravityLabColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    text,
                    style: GravityLabTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

### Card Component
```dart
class GravityLabCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GravityLabColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GravityLabColors.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
```

---

## 4. Animation Standards

### Durations
```dart
class AnimationDurations {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const verySlow = Duration(milliseconds: 1000);
}
```

### Curves
```dart
class AnimationCurves {
  static const easeInOut = Curves.easeInOutCubic;
  static const bounce = Curves.bounceOut;
  static const elastic = Curves.elasticOut;
  static const spring = Curves.fastOutSlowIn;
}
```

### Page Transitions
```dart
class GravityLabPageTransition extends PageRouteBuilder {
  final Widget page;
  
  GravityLabPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationDurations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            var offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
```

---

## 5. Particle Effects System

### Particle Configuration
```dart
class ParticleConfig {
  static const starfield = {
    'count': 50,
    'minSize': 1.0,
    'maxSize': 3.0,
    'speed': 0.5,
    'opacity': 0.7,
  };
  
  static const explosion = {
    'count': 30,
    'minSize': 2.0,
    'maxSize': 6.0,
    'speed': 5.0,
    'lifetime': 1.0,
    'colors': [
      GravityLabColors.accentYellow,
      GravityLabColors.primaryBlue,
      GravityLabColors.secondaryPurple,
    ],
  };
  
  static const trail = {
    'emissionRate': 10,
    'size': 4.0,
    'lifetime': 0.5,
    'fadeOut': true,
  };
}
```

---

## 6. Shader Effects

### Glow Shader
```glsl
// Used for glowing UI elements and energy objects
precision mediump float;
uniform vec2 resolution;
uniform float time;
uniform vec3 color;

void main() {
  vec2 uv = gl_FragCoord.xy / resolution;
  float dist = distance(uv, vec2(0.5));
  float glow = 1.0 - smoothstep(0.0, 0.5, dist);
  glow = pow(glow, 2.0);
  
  vec3 finalColor = color * glow;
  finalColor += vec3(0.1) * sin(time * 2.0) * glow;
  
  gl_FragColor = vec4(finalColor, glow);
}
```

### Distortion Shader
```glsl
// For gravity wells and portals
uniform sampler2D texture;
uniform vec2 center;
uniform float strength;
uniform float time;

void main() {
  vec2 uv = gl_FragCoord.xy / resolution;
  vec2 dir = uv - center;
  float dist = length(dir);
  
  float distortion = sin(dist * 10.0 - time * 3.0) * strength;
  distortion *= 1.0 - smoothstep(0.2, 0.5, dist);
  
  vec2 distortedUV = uv + normalize(dir) * distortion;
  gl_FragColor = texture2D(texture, distortedUV);
}
```

---

## 7. Responsive Design

### Breakpoints
```dart
class Breakpoints {
  static const mobile = 600;
  static const tablet = 900;
  static const desktop = 1200;
}

extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < Breakpoints.mobile;
  bool get isTablet => MediaQuery.of(this).size.width < Breakpoints.tablet;
  bool get isDesktop => MediaQuery.of(this).size.width >= Breakpoints.desktop;
}
```

### Adaptive Layouts
```dart
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMobile ? 2 : context.isTablet ? 3 : 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
```

---

## 8. Icon System

### Custom Icons
```dart
class GravityLabIcons {
  static const gravity = IconData(0xe800, fontFamily: 'GravityLabIcons');
  static const atom = IconData(0xe801, fontFamily: 'GravityLabIcons');
  static const portal = IconData(0xe802, fontFamily: 'GravityLabIcons');
  static const magnet = IconData(0xe803, fontFamily: 'GravityLabIcons');
  static const energy = IconData(0xe804, fontFamily: 'GravityLabIcons');
}
```

---

## 9. Loading States

### Skeleton Loader
```dart
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: GravityLabColors.surface,
      highlightColor: GravityLabColors.surfaceLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: GravityLabColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
```

---

## 10. Theme Configuration

### Complete Theme
```dart
class GravityLabTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: GravityLabColors.background,
    colorScheme: ColorScheme.dark(
      primary: GravityLabColors.primaryBlue,
      secondary: GravityLabColors.secondaryPurple,
      surface: GravityLabColors.surface,
      error: GravityLabColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GravityLabTextStyles.headlineMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}
```

---

This design system provides all the visual building blocks needed to implement Gravity Lab's UI in Flutter!
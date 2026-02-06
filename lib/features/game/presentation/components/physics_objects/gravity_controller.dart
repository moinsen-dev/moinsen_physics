import 'package:flame/components.dart';
import 'dart:math' as math;

/// Controls gravity direction in the game
class GravityController extends Component {
  final Vector2 initialGravity;
  final Function(Vector2 oldGravity, Vector2 newGravity) onGravityChange;
  
  Vector2 currentGravity;
  static const double gravityMagnitude = 98.0; // 10x normal gravity for visible effect
  
  // 8 possible gravity directions
  static final List<Vector2> gravityDirections = [
    Vector2(0, gravityMagnitude),       // Down
    Vector2(0, -gravityMagnitude),      // Up
    Vector2(gravityMagnitude, 0),       // Right
    Vector2(-gravityMagnitude, 0),      // Left
    Vector2(gravityMagnitude / math.sqrt2, gravityMagnitude / math.sqrt2),    // Down-Right
    Vector2(-gravityMagnitude / math.sqrt2, gravityMagnitude / math.sqrt2),   // Down-Left
    Vector2(gravityMagnitude / math.sqrt2, -gravityMagnitude / math.sqrt2),   // Up-Right
    Vector2(-gravityMagnitude / math.sqrt2, -gravityMagnitude / math.sqrt2),  // Up-Left
  ];
  
  GravityController({
    required this.initialGravity,
    required this.onGravityChange,
  }) : currentGravity = initialGravity.clone();
  
  void handleTap(Vector2 tapPosition) {
    // Find closest gravity direction based on tap position relative to screen center
    final screenCenter = Vector2(200, 300); // Assuming 400x600 screen
    final direction = (tapPosition - screenCenter).normalized();
    
    // Find closest predefined direction
    Vector2 closestDirection = gravityDirections[0];
    double minAngle = double.infinity;
    
    for (final gravDir in gravityDirections) {
      final normalizedGrav = gravDir.normalized();
      final angle = math.acos(direction.dot(normalizedGrav).clamp(-1.0, 1.0));
      
      if (angle < minAngle) {
        minAngle = angle;
        closestDirection = gravDir;
      }
    }
    
    if (closestDirection != currentGravity) {
      final oldGravity = currentGravity.clone();
      currentGravity = closestDirection;
      onGravityChange(oldGravity, currentGravity);
    }
  }
  
  void handleDrag(Vector2 dragDelta) {
    // Calculate new gravity direction based on drag
    if (dragDelta.length > 20) { // Minimum drag threshold
      final direction = dragDelta.normalized();
      
      // Find closest predefined direction
      Vector2 closestDirection = gravityDirections[0];
      double minAngle = double.infinity;
      
      for (final gravDir in gravityDirections) {
        final normalizedGrav = gravDir.normalized();
        final angle = math.acos(direction.dot(normalizedGrav).clamp(-1.0, 1.0));
        
        if (angle < minAngle) {
          minAngle = angle;
          closestDirection = gravDir;
        }
      }
      
      if (closestDirection != currentGravity) {
        final oldGravity = currentGravity.clone();
        currentGravity = closestDirection;
        onGravityChange(oldGravity, currentGravity);
      }
    }
  }
  
  void reset() {
    currentGravity = initialGravity.clone();
  }
  
  Vector2 getDirectionFromAngle(double angle) {
    return Vector2(
      math.cos(angle) * gravityMagnitude,
      math.sin(angle) * gravityMagnitude,
    );
  }
}
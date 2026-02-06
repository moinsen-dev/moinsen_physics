import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Manages haptic feedback throughout the game
class HapticManager {
  static bool _isEnabled = true;
  
  /// Check if haptics are enabled
  static bool get isEnabled => _isEnabled;
  
  /// Enable or disable haptic feedback
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  /// Light impact for UI interactions
  static void lightImpact() {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.lightImpact();
  }
  
  /// Medium impact for game events
  static void mediumImpact() {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy impact for significant events
  static void heavyImpact() {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.heavyImpact();
  }
  
  /// Selection click for precise feedback
  static void selectionClick() {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.selectionClick();
  }
  
  /// Vibrate for custom duration (Android only)
  static void vibrate({Duration duration = const Duration(milliseconds: 100)}) {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.vibrate();
  }
  
  /// Gravity switch feedback
  static void gravitySwitch() {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.mediumImpact();
  }
  
  /// Object collision feedback based on force
  static void collision({required double force}) {
    if (!_isEnabled || kIsWeb) return;
    
    if (force < 0.3) {
      HapticFeedback.lightImpact();
    } else if (force < 0.7) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }
  
  /// Victory celebration pattern
  static Future<void> victoryCelebration() async {
    if (!_isEnabled || kIsWeb) return;
    
    // Pattern: light-light-medium-heavy
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
  }
  
  /// Failure feedback
  static Future<void> failure() async {
    if (!_isEnabled || kIsWeb) return;
    
    // Pattern: heavy-medium
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.mediumImpact();
  }
  
  /// Button press feedback
  static void buttonPress() {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.lightImpact();
  }
  
  /// Slider feedback
  static void sliderTick() {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.selectionClick();
  }
  
  /// Star earned feedback
  static Future<void> starEarned() async {
    if (!_isEnabled || kIsWeb) return;
    
    // Pattern: medium-pause-medium-pause-medium
    for (int i = 0; i < 3; i++) {
      HapticFeedback.mediumImpact();
      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }
  
  /// Power-up collected
  static void powerUpCollected() {
    if (!_isEnabled || kIsWeb) return;
    HapticFeedback.mediumImpact();
  }
  
  /// Warning feedback (e.g., time running out)
  static Future<void> warning() async {
    if (!_isEnabled || kIsWeb) return;
    
    // Quick pulses
    for (int i = 0; i < 2; i++) {
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}

/// Haptic feedback patterns
enum HapticPattern {
  success,
  failure,
  warning,
  celebration,
  countdown,
  powerUp,
  unlock,
}

/// Extension for easy haptic feedback on widgets
extension HapticExtension on Widget {
  /// Wrap widget with haptic feedback on tap
  Widget withHaptic({HapticPattern pattern = HapticPattern.success}) {
    return GestureDetector(
      onTap: () {
        switch (pattern) {
          case HapticPattern.success:
            HapticManager.mediumImpact();
            break;
          case HapticPattern.failure:
            HapticManager.failure();
            break;
          case HapticPattern.warning:
            HapticManager.warning();
            break;
          case HapticPattern.celebration:
            HapticManager.victoryCelebration();
            break;
          case HapticPattern.countdown:
            HapticManager.lightImpact();
            break;
          case HapticPattern.powerUp:
            HapticManager.powerUpCollected();
            break;
          case HapticPattern.unlock:
            HapticManager.heavyImpact();
            break;
        }
      },
      child: this as Widget,
    );
  }
}
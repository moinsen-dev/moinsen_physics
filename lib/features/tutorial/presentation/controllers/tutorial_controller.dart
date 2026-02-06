import 'package:flutter/material.dart';
import '../../domain/entities/tutorial_step.dart';
import '../../data/tutorial_scripts.dart';

/// Controls tutorial flow and state
class TutorialController extends ChangeNotifier {
  final String levelId;
  TutorialSequence? _sequence;
  int _currentStepIndex = 0;
  bool _isActive = false;
  bool _isCompleted = false;
  final Map<String, dynamic> _gameState = {};
  
  TutorialController({required this.levelId}) {
    _loadTutorial();
  }
  
  // Getters
  bool get isActive => _isActive;
  bool get isCompleted => _isCompleted;
  int get currentStepIndex => _currentStepIndex;
  double get progress => _sequence == null ? 0.0 
      : (_currentStepIndex + 1) / _sequence!.steps.length;
  
  TutorialStep? get currentStep {
    if (_sequence == null || !_isActive || _isCompleted) return null;
    return _sequence!.getNextStep(_currentStepIndex, _gameState);
  }
  
  void _loadTutorial() {
    _sequence = TutorialScripts.getTutorialForLevel(levelId);
    if (_sequence != null) {
      _isActive = true;
      _gameState.addAll(_sequence!.initialState);
      notifyListeners();
    }
  }
  
  /// Update game state for tutorial validation
  void updateGameState(String key, dynamic value) {
    _gameState[key] = value;
    
    // Check if current step is now completed
    if (currentStep != null && currentStep!.isCompleted(_gameState)) {
      // Auto-advance if configured
      if (currentStep!.autoProceedAfter != null) {
        Future.delayed(currentStep!.autoProceedAfter!, () {
          nextStep();
        });
      }
    }
    
    notifyListeners();
  }
  
  /// Move to next tutorial step
  void nextStep() {
    if (_sequence == null || _isCompleted) return;
    
    _currentStepIndex++;
    
    if (_currentStepIndex >= _sequence!.steps.length) {
      completeTutorial();
    } else {
      notifyListeners();
    }
  }
  
  /// Skip the entire tutorial
  void skipTutorial() {
    if (_sequence == null || !_sequence!.isSkippable) return;
    
    _isActive = false;
    _isCompleted = true;
    _saveTutorialCompletion();
    notifyListeners();
  }
  
  /// Mark tutorial as completed
  void completeTutorial() {
    _isActive = false;
    _isCompleted = true;
    _saveTutorialCompletion();
    notifyListeners();
  }
  
  /// Reset tutorial to beginning
  void resetTutorial() {
    _currentStepIndex = 0;
    _isActive = true;
    _isCompleted = false;
    _gameState.clear();
    if (_sequence != null) {
      _gameState.addAll(_sequence!.initialState);
    }
    notifyListeners();
  }
  
  /// Check if player should see tutorial
  Future<bool> shouldShowTutorial() async {
    // TODO: Check SharedPreferences for completion status
    // For now, always show tutorial for level 1
    return levelId == 'level_1' && !_isCompleted;
  }
  
  void _saveTutorialCompletion() {
    // TODO: Save to SharedPreferences
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool('tutorial_completed_$levelId', true);
    // });
  }
  
  @override
  void dispose() {
    _gameState.clear();
    super.dispose();
  }
}

/// Tutorial state for specific actions
class TutorialActionState {
  final String action;
  final bool isCompleted;
  final int attempts;
  final DateTime? firstAttempt;
  final DateTime? completedAt;
  
  TutorialActionState({
    required this.action,
    this.isCompleted = false,
    this.attempts = 0,
    this.firstAttempt,
    this.completedAt,
  });
  
  TutorialActionState complete() {
    return TutorialActionState(
      action: action,
      isCompleted: true,
      attempts: attempts,
      firstAttempt: firstAttempt,
      completedAt: DateTime.now(),
    );
  }
  
  TutorialActionState addAttempt() {
    return TutorialActionState(
      action: action,
      isCompleted: isCompleted,
      attempts: attempts + 1,
      firstAttempt: firstAttempt ?? DateTime.now(),
      completedAt: completedAt,
    );
  }
}
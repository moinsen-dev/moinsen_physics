import 'package:flame_forge2d/flame_forge2d.dart';
import '../domain/entities/tutorial_step.dart';

/// Tutorial scripts for each level
class TutorialScripts {
  static final Map<String, TutorialSequence> _tutorials = {
    'level_1': _createLevel1Tutorial(),
    'level_2': _createLevel2Tutorial(),
    'level_3': _createLevel3Tutorial(),
    'level_4': _createLevel4Tutorial(),
    'level_5': _createLevel5Tutorial(),
  };
  
  static TutorialSequence? getTutorialForLevel(String levelId) {
    return _tutorials[levelId];
  }
  
  /// Level 1: Basic gravity switching
  static TutorialSequence _createLevel1Tutorial() {
    return TutorialSequence(
      levelId: 'level_1',
      steps: [
        TutorialStep(
          id: 'welcome',
          title: 'Welcome to Gravity Lab!',
          description: 'In this game, you control gravity to guide objects to their goals.',
          action: TutorialAction.showInfo,
          canSkip: false,
          autoProceedAfter: const Duration(seconds: 4),
        ),
        TutorialStep(
          id: 'objective',
          title: 'Your Objective',
          description: 'Guide the green ball into the glowing goal area.',
          action: TutorialAction.highlightArea,
          highlightPosition: Vector2(300, 400), // Goal position
          highlightRadius: 60,
        ),
        TutorialStep(
          id: 'gravity_control',
          title: 'Gravity Control',
          description: 'Tap the gravity buttons to change gravity direction.',
          action: TutorialAction.highlightArea,
          highlightPosition: Vector2(200, 600), // Gravity controls position
          highlightRadius: 80,
        ),
        TutorialStep(
          id: 'try_it',
          title: 'Try It!',
          description: 'Tap the DOWN arrow to make the ball fall.',
          action: TutorialAction.showGhostHand,
          highlightPosition: Vector2(200, 650), // Down button
          validationCriteria: ['gravity_switched'],
        ),
        TutorialStep(
          id: 'success',
          title: 'Great Job!',
          description: 'Now guide the ball to the goal by switching gravity.',
          action: TutorialAction.waitForAction,
          validationCriteria: ['object_reached_goal'],
        ),
      ],
      initialState: {
        'gravity_switched': false,
        'object_reached_goal': false,
        'time_elapsed': 0.0,
      },
    );
  }
  
  /// Level 2: Multiple objects
  static TutorialSequence _createLevel2Tutorial() {
    return TutorialSequence(
      levelId: 'level_2',
      steps: [
        TutorialStep(
          id: 'multiple_objects',
          title: 'Multiple Objects',
          description: 'Now you need to guide TWO balls to their matching colored goals.',
          action: TutorialAction.showInfo,
        ),
        TutorialStep(
          id: 'all_affected',
          title: 'Gravity Affects All',
          description: 'When you change gravity, ALL objects are affected!',
          action: TutorialAction.showInfo,
        ),
        TutorialStep(
          id: 'strategy',
          title: 'Plan Your Moves',
          description: 'Think ahead! Sometimes you need to move objects in stages.',
          action: TutorialAction.showInfo,
        ),
      ],
    );
  }
  
  /// Level 3: Obstacles introduction
  static TutorialSequence _createLevel3Tutorial() {
    return TutorialSequence(
      levelId: 'level_3',
      steps: [
        TutorialStep(
          id: 'obstacles',
          title: 'Watch Out!',
          description: 'Red blocks are obstacles. Objects cannot pass through them.',
          action: TutorialAction.highlightArea,
          highlightPosition: Vector2(200, 300), // Obstacle position
          highlightRadius: 50,
        ),
        TutorialStep(
          id: 'navigation',
          title: 'Navigate Around',
          description: 'Use gravity to navigate around obstacles.',
          action: TutorialAction.showInfo,
        ),
      ],
    );
  }
  
  /// Level 4: Special objects
  static TutorialSequence _createLevel4Tutorial() {
    return TutorialSequence(
      levelId: 'level_4',
      steps: [
        TutorialStep(
          id: 'heavy_object',
          title: 'Heavy Objects',
          description: 'Blue cubes are heavy. They fall faster and can break through weak platforms!',
          action: TutorialAction.highlightArea,
          highlightPosition: Vector2(150, 200), // Heavy object position
          highlightRadius: 40,
        ),
        TutorialStep(
          id: 'light_object',
          title: 'Light Objects',
          description: 'Balloons are light. They fall slowly and can float!',
          action: TutorialAction.highlightArea,
          highlightPosition: Vector2(250, 200), // Light object position
          highlightRadius: 40,
        ),
      ],
    );
  }
  
  /// Level 5: Time limit introduction
  static TutorialSequence _createLevel5Tutorial() {
    return TutorialSequence(
      levelId: 'level_5',
      steps: [
        TutorialStep(
          id: 'time_limit',
          title: 'Beat the Clock!',
          description: 'Some levels have time limits. Complete them quickly for 3 stars!',
          action: TutorialAction.showInfo,
        ),
        TutorialStep(
          id: 'stars',
          title: 'Earn Stars',
          description: 'Complete levels faster and with fewer moves to earn more stars.',
          action: TutorialAction.showInfo,
        ),
        TutorialStep(
          id: 'hint_system',
          title: 'Need Help?',
          description: 'Tap the hint button if you get stuck. You can earn hints by playing!',
          action: TutorialAction.highlightArea,
          highlightPosition: Vector2(50, 50), // Hint button position
          highlightRadius: 30,
        ),
      ],
    );
  }
  
  /// Create a custom tutorial sequence
  static TutorialSequence createCustomTutorial({
    required String levelId,
    required List<TutorialStep> steps,
    Map<String, dynamic> initialState = const {},
  }) {
    return TutorialSequence(
      levelId: levelId,
      steps: steps,
      initialState: initialState,
    );
  }
}

/// Tutorial tips that can be shown between levels
class TutorialTips {
  static const List<String> tips = [
    'Tip: You can change gravity while objects are moving!',
    'Tip: Heavy objects can break weak platforms.',
    'Tip: Some objects stick to surfaces - use this to your advantage!',
    'Tip: Earn 3 stars to unlock bonus levels!',
    'Tip: Watch out for moving platforms in later levels.',
    'Tip: Magnetic objects attract or repel each other.',
    'Tip: Ice blocks slide on surfaces with less friction.',
    'Tip: Ghost orbs can pass through certain materials.',
    'Tip: Energy spheres can power mechanisms.',
    'Tip: Complete daily challenges for extra rewards!',
  ];
  
  static String getRandomTip() {
    return tips[DateTime.now().millisecondsSinceEpoch % tips.length];
  }
}
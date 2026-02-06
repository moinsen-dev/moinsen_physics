import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../levels/domain/entities/world.dart';

/// Service for tracking and managing game progress
class ProgressService {
  // Track total stars earned across all worlds
  int _totalStarsEarned = 0;
  
  // Track world completion data
  final Map<int, WorldProgress> _worldProgress = {};
  
  // Track level completion data
  final Map<String, LevelProgress> _levelProgress = {};
  
  ProgressService() {
    // Initialize with default progress
    _initializeProgress();
  }
  
  /// Initialize default progress state
  void _initializeProgress() {
    // World 1 should always be unlocked by default
    _worldProgress[1] = WorldProgress(
      worldId: 1,
      isUnlocked: true,
      levelsCompleted: 0,
      starsEarned: 0,
      bossDefeated: false,
    );
  }
  
  /// Get total stars earned across all worlds
  int get totalStarsEarned => _totalStarsEarned;
  
  /// Check if a world is unlocked
  bool isWorldUnlocked(int worldId) {
    return _worldProgress[worldId]?.isUnlocked ?? false;
  }
  
  /// Get world progress
  WorldProgress? getWorldProgress(int worldId) {
    return _worldProgress[worldId];
  }
  
  /// Get level progress
  LevelProgress? getLevelProgress(String levelId) {
    return _levelProgress[levelId];
  }
  
  /// Update level progress
  void updateLevelProgress(String levelId, int stars, double time, bool completed) {
    final progress = _levelProgress[levelId] ?? LevelProgress(levelId: levelId);
    
    // Update progress
    progress.starsEarned = stars > progress.starsEarned ? stars : progress.starsEarned;
    progress.bestTime = time < progress.bestTime ? time : progress.bestTime;
    progress.isCompleted = completed || progress.isCompleted;
    progress.attempts++;
    
    _levelProgress[levelId] = progress;
    
    // Update world progress
    final parts = levelId.split('-');
    final worldId = int.parse(parts[0]);
    _updateWorldProgress(worldId);
  }
  
  /// Update world progress based on level completions
  void _updateWorldProgress(int worldId) {
    final worldProgress = _worldProgress[worldId] ?? WorldProgress(worldId: worldId);
    
    // Count completed levels and stars for this world
    int levelsCompleted = 0;
    int starsEarned = 0;
    
    _levelProgress.forEach((levelId, progress) {
      if (levelId.startsWith('$worldId-')) {
        if (progress.isCompleted) levelsCompleted++;
        starsEarned += progress.starsEarned;
      }
    });
    
    worldProgress.levelsCompleted = levelsCompleted;
    worldProgress.starsEarned = starsEarned;
    
    _worldProgress[worldId] = worldProgress;
    
    // Update total stars
    _calculateTotalStars();
  }
  
  /// Calculate total stars across all worlds
  void _calculateTotalStars() {
    _totalStarsEarned = 0;
    _worldProgress.forEach((_, progress) {
      _totalStarsEarned += progress.starsEarned;
    });
  }
  
  /// Check and unlock worlds based on requirements
  void checkWorldUnlocks(List<World> worlds) {
    for (final world in worlds) {
      final requirement = world.unlockRequirement;
      
      // Check if requirement is met
      bool shouldUnlock = false;
      
      if (requirement is StarRequirement) {
        shouldUnlock = _totalStarsEarned >= requirement.requiredStars;
      } else if (requirement is PreviousWorldRequirement) {
        final previousProgress = _worldProgress[requirement.requiredWorldId];
        if (previousProgress != null) {
          final completion = previousProgress.levelsCompleted / 20.0; // Assuming 20 levels per world
          shouldUnlock = completion >= requirement.requiredCompletion;
        }
      } else if (requirement is BossRequirement) {
        final bossWorldProgress = _worldProgress[requirement.bossWorldId];
        shouldUnlock = bossWorldProgress?.bossDefeated ?? false;
      } else if (requirement is CompositeRequirement) {
        // For composite requirements, create a temporary GameProgress to check
        final tempProgress = GameProgress(worlds: {for (var w in worlds) w.id: w});
        tempProgress.totalStarsEarned = _totalStarsEarned;
        shouldUnlock = requirement.isMet(tempProgress);
      }
      
      // Update world unlock status
      final progress = _worldProgress[world.id] ?? WorldProgress(worldId: world.id);
      progress.isUnlocked = shouldUnlock;
      _worldProgress[world.id] = progress;
    }
  }
  
  /// Mark a boss as defeated
  void defeatBoss(int worldId) {
    final progress = _worldProgress[worldId];
    if (progress != null) {
      progress.bossDefeated = true;
    }
  }
  
  /// Load progress from storage (placeholder for future implementation)
  Future<void> loadProgress() async {
    // TODO: Implement loading from SharedPreferences or other storage
    // For now, just ensure World 1 is unlocked
    _initializeProgress();
  }
  
  /// Save progress to storage (placeholder for future implementation)
  Future<void> saveProgress() async {
    // TODO: Implement saving to SharedPreferences or other storage
  }
}

/// Progress data for a world
class WorldProgress {
  final int worldId;
  bool isUnlocked;
  int levelsCompleted;
  int starsEarned;
  bool bossDefeated;
  
  WorldProgress({
    required this.worldId,
    this.isUnlocked = false,
    this.levelsCompleted = 0,
    this.starsEarned = 0,
    this.bossDefeated = false,
  });
}

/// Progress data for a level
class LevelProgress {
  final String levelId;
  bool isCompleted;
  int starsEarned;
  double bestTime;
  int attempts;
  
  LevelProgress({
    required this.levelId,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.bestTime = double.infinity,
    this.attempts = 0,
  });
}

/// Provider for progress service
final progressServiceProvider = Provider<ProgressService>((ref) {
  final service = ProgressService();
  service.loadProgress(); // Load saved progress
  return service;
});
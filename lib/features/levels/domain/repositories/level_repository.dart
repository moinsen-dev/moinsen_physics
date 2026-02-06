import '../entities/level.dart';
import '../entities/world.dart';

/// Repository interface for level management
abstract class LevelRepository {
  /// Load all worlds with their levels
  Future<List<World>> loadAllWorlds();
  
  /// Load a specific world
  Future<World> loadWorld(int worldId);
  
  /// Load a specific level
  Future<Level> loadLevel(String levelId);
  
  /// Save level progress
  Future<void> saveProgress(String levelId, int stars, double time);
  
  /// Load all level progress data
  Future<Map<String, dynamic>> loadLevelProgress();
}
import '../entities/level.dart';
import '../repositories/level_repository.dart';

/// Use case for loading a level
class LoadLevelUseCase {
  final LevelRepository repository;
  
  LoadLevelUseCase(this.repository);
  
  Future<Level> execute(String levelId) async {
    // Validate level ID format
    if (!RegExp(r'^\d+-\d+$').hasMatch(levelId)) {
      throw ArgumentError('Invalid level ID format. Expected: "worldId-levelNumber"');
    }
    
    final level = await repository.loadLevel(levelId);
    
    // Check if level is unlocked
    if (!level.isUnlocked) {
      // Check unlock conditions
      // For now, assume first level of each world is always unlocked
      final parts = levelId.split('-');
      final levelNumber = int.parse(parts[1]);
      
      if (levelNumber == 1) {
        level.isUnlocked = true;
      } else {
        // Check if previous level is completed
        final previousLevelId = '${parts[0]}-${levelNumber - 1}';
        try {
          final previousLevel = await repository.loadLevel(previousLevelId);
          level.isUnlocked = previousLevel.isCompleted;
        } catch (e) {
          level.isUnlocked = false;
        }
      }
    }
    
    return level;
  }
}
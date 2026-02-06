import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moinsen_physics/features/progress/progress_service.dart';
import 'package:moinsen_physics/features/levels/domain/entities/world.dart';

void main() {
  group('ProgressService', () {
    late ProgressService progressService;

    setUp(() {
      progressService = ProgressService();
    });

    test('World 1 should be unlocked by default', () {
      expect(progressService.isWorldUnlocked(1), isTrue);
    });

    test('Other worlds should be locked by default', () {
      expect(progressService.isWorldUnlocked(2), isFalse);
      expect(progressService.isWorldUnlocked(3), isFalse);
      expect(progressService.isWorldUnlocked(4), isFalse);
      expect(progressService.isWorldUnlocked(5), isFalse);
      expect(progressService.isWorldUnlocked(6), isFalse);
    });

    test('Total stars should be 0 initially', () {
      expect(progressService.totalStarsEarned, equals(0));
    });

    test('Should update level progress correctly', () {
      progressService.updateLevelProgress('1-1', 3, 45.5, true);
      
      final levelProgress = progressService.getLevelProgress('1-1');
      expect(levelProgress, isNotNull);
      expect(levelProgress!.starsEarned, equals(3));
      expect(levelProgress.bestTime, equals(45.5));
      expect(levelProgress.isCompleted, isTrue);
      expect(levelProgress.attempts, equals(1));
    });

    test('Should update world progress when levels are completed', () {
      progressService.updateLevelProgress('1-1', 3, 45.5, true);
      progressService.updateLevelProgress('1-2', 2, 60.0, true);
      
      final worldProgress = progressService.getWorldProgress(1);
      expect(worldProgress, isNotNull);
      expect(worldProgress!.levelsCompleted, equals(2));
      expect(worldProgress.starsEarned, equals(5));
    });

    test('Should calculate total stars across worlds', () {
      progressService.updateLevelProgress('1-1', 3, 45.5, true);
      progressService.updateLevelProgress('1-2', 2, 60.0, true);
      progressService.updateLevelProgress('2-1', 1, 90.0, true);
      
      expect(progressService.totalStarsEarned, equals(6));
    });

    test('Should unlock world based on star requirement', () {
      final worlds = [
        World(
          id: 1,
          name: "World 1",
          description: "Test",
          theme: "test",
          visuals: WorldVisuals(
            primaryColor: const Color(0xFF000000),
            secondaryColor: const Color(0xFF000000),
            accentColor: const Color(0xFF000000),
            backgroundAsset: "test.jpg",
            musicTrack: "test.mp3",
            lighting: LightingConfig(
              ambientColor: const Color(0xFF000000),
              ambientIntensity: 1.0,
            ),
          ),
          levels: [],
          unlockRequirement: StarRequirement(requiredStars: 0),
        ),
        World(
          id: 2,
          name: "World 2",
          description: "Test",
          theme: "test",
          visuals: WorldVisuals(
            primaryColor: const Color(0xFF000000),
            secondaryColor: const Color(0xFF000000),
            accentColor: const Color(0xFF000000),
            backgroundAsset: "test.jpg",
            musicTrack: "test.mp3",
            lighting: LightingConfig(
              ambientColor: const Color(0xFF000000),
              ambientIntensity: 1.0,
            ),
          ),
          levels: [],
          unlockRequirement: StarRequirement(requiredStars: 5),
        ),
      ];

      // Initially world 2 should be locked
      progressService.checkWorldUnlocks(worlds);
      expect(progressService.isWorldUnlocked(2), isFalse);

      // After earning 5 stars, world 2 should unlock
      progressService.updateLevelProgress('1-1', 3, 45.5, true);
      progressService.updateLevelProgress('1-2', 2, 60.0, true);
      progressService.checkWorldUnlocks(worlds);
      expect(progressService.isWorldUnlocked(2), isTrue);
    });
  });
}
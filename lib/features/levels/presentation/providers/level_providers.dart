import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/level_repository.dart';
import '../../data/repositories/level_repository_impl.dart';
import '../../../progress/progress_service.dart';

/// Provider for the level repository
final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  final progressService = ref.watch(progressServiceProvider);
  return LevelRepositoryImpl(progressService: progressService);
});
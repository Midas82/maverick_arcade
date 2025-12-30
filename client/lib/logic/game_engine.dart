import 'dart:math';

import '../models/task_model.dart';
import '../data/task_repository.dart';

enum VibeMode {
  chaos, // Random
  beast, // High Energy, FixIt, Home
  zen,   // Low Energy, Self, Creative
  brain, // Medium Energy, Experiments, Self
}

class GameEngine {
  final TaskRepository _repository;
  final Random _random = Random();

  GameEngine(this._repository);

  List<Task> filterTasks(VibeMode mode) {
    final allTasks = _repository.currentTasks;
    if (allTasks.isEmpty) return [];

    switch (mode) {
      case VibeMode.chaos:
        return allTasks;
      case VibeMode.beast:
        return allTasks.where((t) => 
          t.energyLevel == EnergyLevel.high || 
          t.category == TaskCategory.fixIt ||
          t.category == TaskCategory.home
        ).toList();
      case VibeMode.zen:
        return allTasks.where((t) => 
          t.energyLevel == EnergyLevel.low ||
          t.category == TaskCategory.self ||
          t.category == TaskCategory.creative
        ).toList();
      case VibeMode.brain:
        return allTasks.where((t) => 
          t.category == TaskCategory.experiments ||
          (t.category == TaskCategory.self && t.energyLevel == EnergyLevel.medium)
        ).toList();
    }
  }

  Task? spinWheel(VibeMode mode) {
    final pool = filterTasks(mode);
    if (pool.isEmpty) return null;
    return pool[_random.nextInt(pool.length)];
  }
}

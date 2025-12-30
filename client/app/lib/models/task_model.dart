import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

enum TaskCategory {
  home,
  self,
  creative,
  experiments,
  fixIt,
  other,
}

enum EnergyLevel {
  low,
  medium,
  high,
}

@JsonSerializable()
class Task {
  final String id;
  final String title;
  final TaskCategory category;
  final EnergyLevel energyLevel;
  final int durationMinutes;

  Task({
    String? id,
    required this.title,
    required this.category,
    required this.energyLevel,
    required this.durationMinutes,
  }) : id = id ?? const Uuid().v4();

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

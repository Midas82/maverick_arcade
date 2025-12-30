// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String?,
  title: json['title'] as String,
  category: $enumDecode(_$TaskCategoryEnumMap, json['category']),
  energyLevel: $enumDecode(_$EnergyLevelEnumMap, json['energyLevel']),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': _$TaskCategoryEnumMap[instance.category]!,
  'energyLevel': _$EnergyLevelEnumMap[instance.energyLevel]!,
  'durationMinutes': instance.durationMinutes,
};

const _$TaskCategoryEnumMap = {
  TaskCategory.home: 'home',
  TaskCategory.self: 'self',
  TaskCategory.creative: 'creative',
  TaskCategory.experiments: 'experiments',
  TaskCategory.fixIt: 'fixIt',
  TaskCategory.other: 'other',
};

const _$EnergyLevelEnumMap = {
  EnergyLevel.low: 'low',
  EnergyLevel.medium: 'medium',
  EnergyLevel.high: 'high',
};

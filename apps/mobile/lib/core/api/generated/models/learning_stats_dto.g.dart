// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningStatsDto _$LearningStatsDtoFromJson(Map<String, dynamic> json) =>
    LearningStatsDto(
      inProgress: json['inProgress'] as num,
      completed: json['completed'] as num,
      minutesThisMonth: json['minutesThisMonth'] as num,
      hoursThisMonth: json['hoursThisMonth'] as num,
    );

Map<String, dynamic> _$LearningStatsDtoToJson(LearningStatsDto instance) =>
    <String, dynamic>{
      'inProgress': instance.inProgress,
      'completed': instance.completed,
      'minutesThisMonth': instance.minutesThisMonth,
      'hoursThisMonth': instance.hoursThisMonth,
    };

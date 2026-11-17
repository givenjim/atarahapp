// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_progress_body_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonProgressBodyDto _$LessonProgressBodyDtoFromJson(
  Map<String, dynamic> json,
) => LessonProgressBodyDto(
  positionSeconds: json['positionSeconds'] as num?,
  completed: json['completed'] as bool?,
  restart: json['restart'] as bool?,
);

Map<String, dynamic> _$LessonProgressBodyDtoToJson(
  LessonProgressBodyDto instance,
) => <String, dynamic>{
  'positionSeconds': instance.positionSeconds,
  'completed': instance.completed,
  'restart': instance.restart,
};

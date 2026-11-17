// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_progress_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonProgressDto _$LessonProgressDtoFromJson(Map<String, dynamic> json) =>
    LessonProgressDto(
      status: LessonProgressStatus.fromJson(json['status'] as String),
      lastPositionSeconds: json['lastPositionSeconds'] as num,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$LessonProgressDtoToJson(LessonProgressDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'lastPositionSeconds': instance.lastPositionSeconds,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

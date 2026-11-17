// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_video_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonVideoDto _$LessonVideoDtoFromJson(Map<String, dynamic> json) =>
    LessonVideoDto(
      url: json['url'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      posterUrl: json['posterUrl'] as String?,
      durationSeconds: json['durationSeconds'] as num?,
    );

Map<String, dynamic> _$LessonVideoDtoToJson(LessonVideoDto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'posterUrl': instance.posterUrl,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
    };

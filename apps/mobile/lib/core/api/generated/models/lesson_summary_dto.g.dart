// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonSummaryDto _$LessonSummaryDtoFromJson(Map<String, dynamic> json) =>
    LessonSummaryDto(
      id: json['id'] as String,
      sequence: json['sequence'] as num,
      title: json['title'] as String,
      durationMinutes: json['durationMinutes'] as num,
      state: LessonSummaryDtoState.fromJson(json['state'] as String),
      hasVideo: json['hasVideo'] as bool,
      hasEmbed: json['hasEmbed'] as bool,
    );

Map<String, dynamic> _$LessonSummaryDtoToJson(LessonSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sequence': instance.sequence,
      'title': instance.title,
      'durationMinutes': instance.durationMinutes,
      'state': instance.state,
      'hasVideo': instance.hasVideo,
      'hasEmbed': instance.hasEmbed,
    };

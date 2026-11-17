// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonFieldsDto _$LessonFieldsDtoFromJson(Map<String, dynamic> json) =>
    LessonFieldsDto(
      title: json['title'] as String,
      durationMinutes: json['durationMinutes'] as num?,
      body: (json['body'] as List<dynamic>?)
          ?.map((e) => ArticleBlockInputDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoMediaId: json['videoMediaId'] as String?,
      embedUrl: json['embedUrl'] as String?,
      practicePrompt: json['practicePrompt'] as String?,
      practiceSkillId: json['practiceSkillId'] as String?,
    );

Map<String, dynamic> _$LessonFieldsDtoToJson(LessonFieldsDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'durationMinutes': instance.durationMinutes,
      'body': instance.body,
      'videoMediaId': instance.videoMediaId,
      'embedUrl': instance.embedUrl,
      'practicePrompt': instance.practicePrompt,
      'practiceSkillId': instance.practiceSkillId,
    };

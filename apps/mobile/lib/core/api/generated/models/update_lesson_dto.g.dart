// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_lesson_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateLessonDto _$UpdateLessonDtoFromJson(Map<String, dynamic> json) =>
    UpdateLessonDto(
      title: json['title'] as String?,
      durationMinutes: json['durationMinutes'] as num?,
      body: (json['body'] as List<dynamic>?)
          ?.map((e) => ArticleBlockInputDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoMediaId: json['videoMediaId'] as String?,
      embedUrl: json['embedUrl'] as String?,
      practicePrompt: json['practicePrompt'] as String?,
      practiceSkillId: json['practiceSkillId'] as String?,
    );

Map<String, dynamic> _$UpdateLessonDtoToJson(UpdateLessonDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'durationMinutes': instance.durationMinutes,
      'body': instance.body,
      'videoMediaId': instance.videoMediaId,
      'embedUrl': instance.embedUrl,
      'practicePrompt': instance.practicePrompt,
      'practiceSkillId': instance.practiceSkillId,
    };

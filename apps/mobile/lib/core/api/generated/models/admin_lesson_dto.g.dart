// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_lesson_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminLessonDto _$AdminLessonDtoFromJson(Map<String, dynamic> json) =>
    AdminLessonDto(
      id: json['id'] as String,
      sequence: json['sequence'] as num,
      title: json['title'] as String,
      durationMinutes: json['durationMinutes'] as num,
      body: (json['body'] as List<dynamic>)
          .map((e) => ArticleBlockDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoMediaId: json['videoMediaId'] as String?,
      videoStatus: json['videoStatus'] as String?,
      embedUrl: json['embedUrl'] as String?,
      practicePrompt: json['practicePrompt'] as String?,
      practiceSkillId: json['practiceSkillId'] as String?,
    );

Map<String, dynamic> _$AdminLessonDtoToJson(AdminLessonDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sequence': instance.sequence,
      'title': instance.title,
      'durationMinutes': instance.durationMinutes,
      'body': instance.body,
      'videoMediaId': instance.videoMediaId,
      'videoStatus': instance.videoStatus,
      'embedUrl': instance.embedUrl,
      'practicePrompt': instance.practicePrompt,
      'practiceSkillId': instance.practiceSkillId,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonDto _$LessonDtoFromJson(Map<String, dynamic> json) => LessonDto(
  id: json['id'] as String,
  courseId: json['courseId'] as String,
  courseTitle: json['courseTitle'] as String,
  sequence: json['sequence'] as num,
  lessonCount: json['lessonCount'] as num,
  title: json['title'] as String,
  durationMinutes: json['durationMinutes'] as num,
  body: (json['body'] as List<dynamic>)
      .map((e) => ArticleBlockDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasVideo: json['hasVideo'] as bool,
  progress: LessonProgressDto.fromJson(
    json['progress'] as Map<String, dynamic>,
  ),
  state: LessonDtoState.fromJson(json['state'] as String),
  segments: (json['segments'] as List<dynamic>).map((e) => e as bool).toList(),
  practice: json['practice'] == null
      ? null
      : PracticeDto.fromJson(json['practice'] as Map<String, dynamic>),
  embedUrl: json['embedUrl'] as String?,
  previousLessonId: json['previousLessonId'] as String?,
  nextLessonId: json['nextLessonId'] as String?,
);

Map<String, dynamic> _$LessonDtoToJson(LessonDto instance) => <String, dynamic>{
  'id': instance.id,
  'courseId': instance.courseId,
  'courseTitle': instance.courseTitle,
  'sequence': instance.sequence,
  'lessonCount': instance.lessonCount,
  'title': instance.title,
  'durationMinutes': instance.durationMinutes,
  'body': instance.body,
  'practice': instance.practice,
  'hasVideo': instance.hasVideo,
  'embedUrl': instance.embedUrl,
  'progress': instance.progress,
  'state': instance.state,
  'previousLessonId': instance.previousLessonId,
  'nextLessonId': instance.nextLessonId,
  'segments': instance.segments,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_courses_id_lessons_lesson_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminCoursesIdLessonsLessonIdResponse
_$PatchApiV1AdminCoursesIdLessonsLessonIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminCoursesIdLessonsLessonIdResponse(
  data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminCoursesIdLessonsLessonIdResponseToJson(
  PatchApiV1AdminCoursesIdLessonsLessonIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

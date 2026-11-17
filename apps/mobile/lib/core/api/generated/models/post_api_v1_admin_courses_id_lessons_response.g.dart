// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_courses_id_lessons_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminCoursesIdLessonsResponse
_$PostApiV1AdminCoursesIdLessonsResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminCoursesIdLessonsResponse(
      data: AdminContentDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminCoursesIdLessonsResponseToJson(
  PostApiV1AdminCoursesIdLessonsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

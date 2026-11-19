// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_content_dto.dart';

part 'delete_api_v1_admin_courses_id_lessons_lesson_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1AdminCoursesIdLessonsLessonIdResponse {
  const DeleteApiV1AdminCoursesIdLessonsLessonIdResponse({
    required this.data,
    this.meta,
  });
  
  factory DeleteApiV1AdminCoursesIdLessonsLessonIdResponse.fromJson(Map<String, Object?> json) => _$DeleteApiV1AdminCoursesIdLessonsLessonIdResponseFromJson(json);
  
  final AdminContentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$DeleteApiV1AdminCoursesIdLessonsLessonIdResponseToJson(this);
}

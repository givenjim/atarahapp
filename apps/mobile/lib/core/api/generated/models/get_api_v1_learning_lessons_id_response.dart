// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_dto.dart';

part 'get_api_v1_learning_lessons_id_response.g.dart';

@JsonSerializable()
class GetApiV1LearningLessonsIdResponse {
  const GetApiV1LearningLessonsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1LearningLessonsIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1LearningLessonsIdResponseFromJson(json);
  
  final LessonDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1LearningLessonsIdResponseToJson(this);
}

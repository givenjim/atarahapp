// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_video_dto.dart';

part 'get_api_v1_learning_lessons_id_video_response.g.dart';

@JsonSerializable()
class GetApiV1LearningLessonsIdVideoResponse {
  const GetApiV1LearningLessonsIdVideoResponse({required this.data, this.meta});

  factory GetApiV1LearningLessonsIdVideoResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1LearningLessonsIdVideoResponseFromJson(json);

  final LessonVideoDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1LearningLessonsIdVideoResponseToJson(this);
}

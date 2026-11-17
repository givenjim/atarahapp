// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'progress_result_dto.dart';

part 'put_api_v1_learning_lessons_id_progress_response.g.dart';

@JsonSerializable()
class PutApiV1LearningLessonsIdProgressResponse {
  const PutApiV1LearningLessonsIdProgressResponse({
    required this.data,
    this.meta,
  });

  factory PutApiV1LearningLessonsIdProgressResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PutApiV1LearningLessonsIdProgressResponseFromJson(json);

  final ProgressResultDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PutApiV1LearningLessonsIdProgressResponseToJson(this);
}

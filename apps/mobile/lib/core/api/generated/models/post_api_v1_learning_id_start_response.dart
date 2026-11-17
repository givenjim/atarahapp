// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_item_progress_dto.dart';

part 'post_api_v1_learning_id_start_response.g.dart';

@JsonSerializable()
class PostApiV1LearningIdStartResponse {
  const PostApiV1LearningIdStartResponse({required this.data, this.meta});

  factory PostApiV1LearningIdStartResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1LearningIdStartResponseFromJson(json);

  final LearningItemProgressDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1LearningIdStartResponseToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'override_result_dto.dart';

part 'post_api_v1_admin_learning_progress_overrides_response.g.dart';

@JsonSerializable()
class PostApiV1AdminLearningProgressOverridesResponse {
  const PostApiV1AdminLearningProgressOverridesResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminLearningProgressOverridesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminLearningProgressOverridesResponseFromJson(json);

  final OverrideResultDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminLearningProgressOverridesResponseToJson(this);
}

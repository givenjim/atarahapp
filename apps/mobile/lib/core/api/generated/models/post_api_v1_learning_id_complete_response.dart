// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_item_progress_dto.dart';

part 'post_api_v1_learning_id_complete_response.g.dart';

@JsonSerializable()
class PostApiV1LearningIdCompleteResponse {
  const PostApiV1LearningIdCompleteResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1LearningIdCompleteResponse.fromJson(Map<String, Object?> json) => _$PostApiV1LearningIdCompleteResponseFromJson(json);
  
  final LearningItemProgressDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1LearningIdCompleteResponseToJson(this);
}

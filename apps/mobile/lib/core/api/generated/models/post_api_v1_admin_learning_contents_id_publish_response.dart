// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_content_dto.dart';

part 'post_api_v1_admin_learning_contents_id_publish_response.g.dart';

@JsonSerializable()
class PostApiV1AdminLearningContentsIdPublishResponse {
  const PostApiV1AdminLearningContentsIdPublishResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminLearningContentsIdPublishResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminLearningContentsIdPublishResponseFromJson(json);

  final AdminContentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminLearningContentsIdPublishResponseToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_content_dto.dart';

part 'patch_api_v1_admin_learning_contents_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminLearningContentsIdResponse {
  const PatchApiV1AdminLearningContentsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1AdminLearningContentsIdResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1AdminLearningContentsIdResponseFromJson(json);
  
  final AdminContentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminLearningContentsIdResponseToJson(this);
}

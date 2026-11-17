// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'comment_view_dto.dart';

part 'patch_api_v1_comments_id_response.g.dart';

@JsonSerializable()
class PatchApiV1CommentsIdResponse {
  const PatchApiV1CommentsIdResponse({required this.data, this.meta});

  factory PatchApiV1CommentsIdResponse.fromJson(Map<String, Object?> json) =>
      _$PatchApiV1CommentsIdResponseFromJson(json);

  final CommentViewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1CommentsIdResponseToJson(this);
}

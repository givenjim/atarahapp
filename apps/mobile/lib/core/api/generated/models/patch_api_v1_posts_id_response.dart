// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_view_dto.dart';

part 'patch_api_v1_posts_id_response.g.dart';

@JsonSerializable()
class PatchApiV1PostsIdResponse {
  const PatchApiV1PostsIdResponse({required this.data, this.meta});

  factory PatchApiV1PostsIdResponse.fromJson(Map<String, Object?> json) =>
      _$PatchApiV1PostsIdResponseFromJson(json);

  final PostViewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1PostsIdResponseToJson(this);
}

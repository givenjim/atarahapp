// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'comment_view_dto.dart';

part 'get_api_v1_posts_id_comments_response.g.dart';

@JsonSerializable()
class GetApiV1PostsIdCommentsResponse {
  const GetApiV1PostsIdCommentsResponse({required this.data, this.meta});

  factory GetApiV1PostsIdCommentsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1PostsIdCommentsResponseFromJson(json);

  final List<CommentViewDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1PostsIdCommentsResponseToJson(this);
}

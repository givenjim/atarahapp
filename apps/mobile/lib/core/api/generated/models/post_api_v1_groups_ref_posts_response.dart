// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_view_dto.dart';

part 'post_api_v1_groups_ref_posts_response.g.dart';

@JsonSerializable()
class PostApiV1GroupsRefPostsResponse {
  const PostApiV1GroupsRefPostsResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1GroupsRefPostsResponse.fromJson(Map<String, Object?> json) => _$PostApiV1GroupsRefPostsResponseFromJson(json);
  
  final PostViewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1GroupsRefPostsResponseToJson(this);
}

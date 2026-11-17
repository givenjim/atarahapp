// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_view_dto.dart';

part 'get_api_v1_groups_ref_posts_response.g.dart';

@JsonSerializable()
class GetApiV1GroupsRefPostsResponse {
  const GetApiV1GroupsRefPostsResponse({required this.data, this.meta});

  factory GetApiV1GroupsRefPostsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1GroupsRefPostsResponseFromJson(json);

  final List<PostViewDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1GroupsRefPostsResponseToJson(this);
}

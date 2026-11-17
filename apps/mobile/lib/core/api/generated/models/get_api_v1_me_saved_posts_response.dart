// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_view_dto.dart';

part 'get_api_v1_me_saved_posts_response.g.dart';

@JsonSerializable()
class GetApiV1MeSavedPostsResponse {
  const GetApiV1MeSavedPostsResponse({required this.data, this.meta});

  factory GetApiV1MeSavedPostsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeSavedPostsResponseFromJson(json);

  final List<PostViewDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeSavedPostsResponseToJson(this);
}

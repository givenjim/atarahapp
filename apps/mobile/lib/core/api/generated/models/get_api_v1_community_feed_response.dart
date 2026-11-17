// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_view_dto.dart';

part 'get_api_v1_community_feed_response.g.dart';

@JsonSerializable()
class GetApiV1CommunityFeedResponse {
  const GetApiV1CommunityFeedResponse({required this.data, this.meta});

  factory GetApiV1CommunityFeedResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1CommunityFeedResponseFromJson(json);

  final List<PostViewDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1CommunityFeedResponseToJson(this);
}

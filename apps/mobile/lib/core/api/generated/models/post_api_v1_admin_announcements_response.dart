// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_view_dto.dart';

part 'post_api_v1_admin_announcements_response.g.dart';

@JsonSerializable()
class PostApiV1AdminAnnouncementsResponse {
  const PostApiV1AdminAnnouncementsResponse({required this.data, this.meta});

  factory PostApiV1AdminAnnouncementsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminAnnouncementsResponseFromJson(json);

  final PostViewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminAnnouncementsResponseToJson(this);
}

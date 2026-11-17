// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'audience_preview_dto.dart';

part 'post_api_v1_admin_notifications_broadcasts_preview_response.g.dart';

@JsonSerializable()
class PostApiV1AdminNotificationsBroadcastsPreviewResponse {
  const PostApiV1AdminNotificationsBroadcastsPreviewResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminNotificationsBroadcastsPreviewResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminNotificationsBroadcastsPreviewResponseFromJson(json);

  final AudiencePreviewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminNotificationsBroadcastsPreviewResponseToJson(this);
}

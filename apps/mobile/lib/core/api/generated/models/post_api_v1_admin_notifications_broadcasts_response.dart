// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'broadcast_dto.dart';

part 'post_api_v1_admin_notifications_broadcasts_response.g.dart';

@JsonSerializable()
class PostApiV1AdminNotificationsBroadcastsResponse {
  const PostApiV1AdminNotificationsBroadcastsResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminNotificationsBroadcastsResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminNotificationsBroadcastsResponseFromJson(json);
  
  final BroadcastDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminNotificationsBroadcastsResponseToJson(this);
}

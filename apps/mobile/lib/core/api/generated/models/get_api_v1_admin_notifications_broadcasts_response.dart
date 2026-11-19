// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'broadcast_dto.dart';

part 'get_api_v1_admin_notifications_broadcasts_response.g.dart';

@JsonSerializable()
class GetApiV1AdminNotificationsBroadcastsResponse {
  const GetApiV1AdminNotificationsBroadcastsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminNotificationsBroadcastsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminNotificationsBroadcastsResponseFromJson(json);
  
  final List<BroadcastDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminNotificationsBroadcastsResponseToJson(this);
}

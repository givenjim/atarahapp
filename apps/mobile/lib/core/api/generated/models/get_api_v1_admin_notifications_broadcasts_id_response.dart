// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'broadcast_dto.dart';

part 'get_api_v1_admin_notifications_broadcasts_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminNotificationsBroadcastsIdResponse {
  const GetApiV1AdminNotificationsBroadcastsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminNotificationsBroadcastsIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminNotificationsBroadcastsIdResponseFromJson(json);
  
  final BroadcastDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminNotificationsBroadcastsIdResponseToJson(this);
}

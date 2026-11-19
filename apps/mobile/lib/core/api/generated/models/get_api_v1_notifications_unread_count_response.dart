// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'unread_count_dto.dart';

part 'get_api_v1_notifications_unread_count_response.g.dart';

@JsonSerializable()
class GetApiV1NotificationsUnreadCountResponse {
  const GetApiV1NotificationsUnreadCountResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1NotificationsUnreadCountResponse.fromJson(Map<String, Object?> json) => _$GetApiV1NotificationsUnreadCountResponseFromJson(json);
  
  final UnreadCountDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1NotificationsUnreadCountResponseToJson(this);
}

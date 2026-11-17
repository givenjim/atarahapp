// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'notification_item_dto.dart';

part 'get_api_v1_notifications_response.g.dart';

@JsonSerializable()
class GetApiV1NotificationsResponse {
  const GetApiV1NotificationsResponse({required this.data, this.meta});

  factory GetApiV1NotificationsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1NotificationsResponseFromJson(json);

  final List<NotificationItemDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1NotificationsResponseToJson(this);
}

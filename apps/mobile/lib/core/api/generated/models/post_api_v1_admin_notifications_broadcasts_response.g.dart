// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_notifications_broadcasts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminNotificationsBroadcastsResponse
_$PostApiV1AdminNotificationsBroadcastsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminNotificationsBroadcastsResponse(
  data: BroadcastDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminNotificationsBroadcastsResponseToJson(
  PostApiV1AdminNotificationsBroadcastsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

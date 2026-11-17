// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_notifications_broadcasts_id_cancel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminNotificationsBroadcastsIdCancelResponse
_$PostApiV1AdminNotificationsBroadcastsIdCancelResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminNotificationsBroadcastsIdCancelResponse(
  data: BroadcastDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminNotificationsBroadcastsIdCancelResponseToJson(
  PostApiV1AdminNotificationsBroadcastsIdCancelResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

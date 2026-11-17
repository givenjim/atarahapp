// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_notifications_broadcasts_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminNotificationsBroadcastsIdResponse
_$GetApiV1AdminNotificationsBroadcastsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminNotificationsBroadcastsIdResponse(
  data: BroadcastDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminNotificationsBroadcastsIdResponseToJson(
  GetApiV1AdminNotificationsBroadcastsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

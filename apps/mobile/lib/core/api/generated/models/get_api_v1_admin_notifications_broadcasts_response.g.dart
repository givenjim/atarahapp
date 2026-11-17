// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_notifications_broadcasts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminNotificationsBroadcastsResponse
_$GetApiV1AdminNotificationsBroadcastsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminNotificationsBroadcastsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => BroadcastDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminNotificationsBroadcastsResponseToJson(
  GetApiV1AdminNotificationsBroadcastsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

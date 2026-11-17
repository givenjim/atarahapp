// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_notifications_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1NotificationsResponse _$GetApiV1NotificationsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1NotificationsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => NotificationItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1NotificationsResponseToJson(
  GetApiV1NotificationsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

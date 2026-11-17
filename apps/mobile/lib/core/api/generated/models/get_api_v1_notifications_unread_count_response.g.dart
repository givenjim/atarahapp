// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_notifications_unread_count_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1NotificationsUnreadCountResponse
_$GetApiV1NotificationsUnreadCountResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1NotificationsUnreadCountResponse(
      data: UnreadCountDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1NotificationsUnreadCountResponseToJson(
  GetApiV1NotificationsUnreadCountResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

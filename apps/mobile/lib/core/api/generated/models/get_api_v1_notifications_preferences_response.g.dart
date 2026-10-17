// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_notifications_preferences_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1NotificationsPreferencesResponse
_$GetApiV1NotificationsPreferencesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1NotificationsPreferencesResponse(
      data: PreferencesDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1NotificationsPreferencesResponseToJson(
  GetApiV1NotificationsPreferencesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

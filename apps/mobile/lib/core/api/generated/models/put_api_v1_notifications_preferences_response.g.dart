// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_notifications_preferences_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1NotificationsPreferencesResponse
_$PutApiV1NotificationsPreferencesResponseFromJson(Map<String, dynamic> json) =>
    PutApiV1NotificationsPreferencesResponse(
      data: PreferencesDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PutApiV1NotificationsPreferencesResponseToJson(
  PutApiV1NotificationsPreferencesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_preferences_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MePreferencesResponse _$GetApiV1MePreferencesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MePreferencesResponse(
  data: AccountPreferencesDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MePreferencesResponseToJson(
  GetApiV1MePreferencesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

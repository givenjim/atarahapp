// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_preferences_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MePreferencesResponse _$PatchApiV1MePreferencesResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MePreferencesResponse(
  data: AccountPreferencesDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MePreferencesResponseToJson(
  PatchApiV1MePreferencesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

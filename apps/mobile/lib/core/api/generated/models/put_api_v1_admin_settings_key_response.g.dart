// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_admin_settings_key_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1AdminSettingsKeyResponse _$PutApiV1AdminSettingsKeyResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1AdminSettingsKeyResponse(
  data: PlatformSettingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1AdminSettingsKeyResponseToJson(
  PutApiV1AdminSettingsKeyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

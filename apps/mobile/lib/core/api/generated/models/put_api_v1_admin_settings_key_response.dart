// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'platform_setting_dto.dart';

part 'put_api_v1_admin_settings_key_response.g.dart';

@JsonSerializable()
class PutApiV1AdminSettingsKeyResponse {
  const PutApiV1AdminSettingsKeyResponse({
    required this.data,
    this.meta,
  });
  
  factory PutApiV1AdminSettingsKeyResponse.fromJson(Map<String, Object?> json) => _$PutApiV1AdminSettingsKeyResponseFromJson(json);
  
  final PlatformSettingDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1AdminSettingsKeyResponseToJson(this);
}

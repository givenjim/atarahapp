// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'platform_setting_dto.dart';

part 'get_api_v1_admin_settings_response.g.dart';

@JsonSerializable()
class GetApiV1AdminSettingsResponse {
  const GetApiV1AdminSettingsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminSettingsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminSettingsResponseFromJson(json);
  
  final List<PlatformSettingDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminSettingsResponseToJson(this);
}

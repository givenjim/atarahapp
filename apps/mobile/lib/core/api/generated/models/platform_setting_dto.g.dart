// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_setting_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformSettingDto _$PlatformSettingDtoFromJson(Map<String, dynamic> json) =>
    PlatformSettingDto(
      key: json['key'] as String,
      value: json['value'],
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PlatformSettingDtoToJson(PlatformSettingDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'description': instance.description,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flag_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureFlagDto _$FeatureFlagDtoFromJson(Map<String, dynamic> json) =>
    FeatureFlagDto(
      key: json['key'] as String,
      description: json['description'] as String,
      enabled: json['enabled'] as bool,
      phase: json['phase'] as num,
    );

Map<String, dynamic> _$FeatureFlagDtoToJson(FeatureFlagDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'description': instance.description,
      'enabled': instance.enabled,
      'phase': instance.phase,
    };

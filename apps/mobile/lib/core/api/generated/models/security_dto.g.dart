// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityDto _$SecurityDtoFromJson(Map<String, dynamic> json) => SecurityDto(
  factors: (json['factors'] as List<dynamic>)
      .map((e) => MfaFactorDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  twoStepEnabled: json['twoStepEnabled'] as bool,
  hasVerifiedFactor: json['hasVerifiedFactor'] as bool,
  activeSessions: json['activeSessions'] as num,
  deviceCount: json['deviceCount'] as num,
);

Map<String, dynamic> _$SecurityDtoToJson(SecurityDto instance) =>
    <String, dynamic>{
      'factors': instance.factors,
      'twoStepEnabled': instance.twoStepEnabled,
      'hasVerifiedFactor': instance.hasVerifiedFactor,
      'activeSessions': instance.activeSessions,
      'deviceCount': instance.deviceCount,
    };

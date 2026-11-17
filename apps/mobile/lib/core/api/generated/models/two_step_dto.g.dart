// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'two_step_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwoStepDto _$TwoStepDtoFromJson(Map<String, dynamic> json) => TwoStepDto(
  enabled: json['enabled'] as bool,
  hasVerifiedFactor: json['hasVerifiedFactor'] as bool,
);

Map<String, dynamic> _$TwoStepDtoToJson(TwoStepDto instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'hasVerifiedFactor': instance.hasVerifiedFactor,
    };

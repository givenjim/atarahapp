// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_login_step_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminLoginStepDto _$AdminLoginStepDtoFromJson(Map<String, dynamic> json) =>
    AdminLoginStepDto(
      step: AdminLoginStepDtoStep.fromJson(json['step'] as String),
      challengeToken: json['challengeToken'] as String,
    );

Map<String, dynamic> _$AdminLoginStepDtoToJson(AdminLoginStepDto instance) =>
    <String, dynamic>{
      'step': instance.step,
      'challengeToken': instance.challengeToken,
    };

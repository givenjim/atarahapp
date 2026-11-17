// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_case_action_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCaseActionDto _$AdminCaseActionDtoFromJson(Map<String, dynamic> json) =>
    AdminCaseActionDto(
      id: json['id'] as String,
      action: ModerationAction.fromJson(json['action'] as String),
      reason: json['reason'] as String?,
      actor: json['actor'] == null
          ? null
          : AdminPersonRefDto.fromJson(json['actor'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminCaseActionDtoToJson(AdminCaseActionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'reason': instance.reason,
      'actor': instance.actor,
      'createdAt': instance.createdAt.toIso8601String(),
    };

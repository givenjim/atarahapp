// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_action_body_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModerationActionBodyDto _$ModerationActionBodyDtoFromJson(
  Map<String, dynamic> json,
) => ModerationActionBodyDto(
  action: ModerationAction.fromJson(json['action'] as String),
  reason: json['reason'] as String?,
  restrictDays: json['restrictDays'] as num?,
);

Map<String, dynamic> _$ModerationActionBodyDtoToJson(
  ModerationActionBodyDto instance,
) => <String, dynamic>{
  'action': instance.action,
  'reason': instance.reason,
  'restrictDays': instance.restrictDays,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mute_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MuteStateDto _$MuteStateDtoFromJson(Map<String, dynamic> json) => MuteStateDto(
  targetType: MuteTargetType.fromJson(json['targetType'] as String),
  targetId: json['targetId'] as String,
  muted: json['muted'] as bool,
);

Map<String, dynamic> _$MuteStateDtoToJson(MuteStateDto instance) =>
    <String, dynamic>{
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'muted': instance.muted,
    };

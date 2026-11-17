// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mute_target_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MuteTargetDto _$MuteTargetDtoFromJson(Map<String, dynamic> json) =>
    MuteTargetDto(
      targetType: MuteTargetType.fromJson(json['targetType'] as String),
      targetId: json['targetId'] as String?,
      handle: json['handle'] as String?,
    );

Map<String, dynamic> _$MuteTargetDtoToJson(MuteTargetDto instance) =>
    <String, dynamic>{
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'handle': instance.handle,
    };

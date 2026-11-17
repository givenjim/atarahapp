// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mute_target_type.dart';

part 'mute_state_dto.g.dart';

@JsonSerializable()
class MuteStateDto {
  const MuteStateDto({
    required this.targetType,
    required this.targetId,
    required this.muted,
  });

  factory MuteStateDto.fromJson(Map<String, Object?> json) =>
      _$MuteStateDtoFromJson(json);

  final MuteTargetType targetType;
  final String targetId;
  final bool muted;

  Map<String, Object?> toJson() => _$MuteStateDtoToJson(this);
}

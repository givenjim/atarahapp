// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mute_target_type.dart';

part 'mute_target_dto.g.dart';

@JsonSerializable()
class MuteTargetDto {
  const MuteTargetDto({
    required this.targetType,
    this.targetId,
    this.handle,
  });
  
  factory MuteTargetDto.fromJson(Map<String, Object?> json) => _$MuteTargetDtoFromJson(json);
  
  final MuteTargetType targetType;

  /// A user id (USER) or a post id (POST).
  final String? targetId;

  /// For USER: the handle, instead of `targetId`.
  final String? handle;

  Map<String, Object?> toJson() => _$MuteTargetDtoToJson(this);
}

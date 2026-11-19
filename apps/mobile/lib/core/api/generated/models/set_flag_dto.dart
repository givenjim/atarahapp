// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_flag_dto.g.dart';

@JsonSerializable()
class SetFlagDto {
  const SetFlagDto({
    required this.enabled,
  });
  
  factory SetFlagDto.fromJson(Map<String, Object?> json) => _$SetFlagDtoFromJson(json);
  
  final bool enabled;

  Map<String, Object?> toJson() => _$SetFlagDtoToJson(this);
}

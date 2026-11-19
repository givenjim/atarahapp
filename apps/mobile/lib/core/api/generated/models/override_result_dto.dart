// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'override_result_dto.g.dart';

@JsonSerializable()
class OverrideResultDto {
  const OverrideResultDto({
    required this.ok,
    required this.courseCompleted,
  });
  
  factory OverrideResultDto.fromJson(Map<String, Object?> json) => _$OverrideResultDtoFromJson(json);
  
  final bool ok;
  final bool courseCompleted;

  Map<String, Object?> toJson() => _$OverrideResultDtoToJson(this);
}

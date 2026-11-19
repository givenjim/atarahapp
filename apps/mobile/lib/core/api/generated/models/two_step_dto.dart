// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'two_step_dto.g.dart';

@JsonSerializable()
class TwoStepDto {
  const TwoStepDto({
    required this.enabled,
    required this.hasVerifiedFactor,
  });
  
  factory TwoStepDto.fromJson(Map<String, Object?> json) => _$TwoStepDtoFromJson(json);
  
  final bool enabled;
  final bool hasVerifiedFactor;

  Map<String, Object?> toJson() => _$TwoStepDtoToJson(this);
}

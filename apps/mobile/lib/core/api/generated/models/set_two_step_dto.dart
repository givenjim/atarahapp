// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_two_step_dto.g.dart';

@JsonSerializable()
class SetTwoStepDto {
  const SetTwoStepDto({required this.enabled});

  factory SetTwoStepDto.fromJson(Map<String, Object?> json) =>
      _$SetTwoStepDtoFromJson(json);

  final bool enabled;

  Map<String, Object?> toJson() => _$SetTwoStepDtoToJson(this);
}

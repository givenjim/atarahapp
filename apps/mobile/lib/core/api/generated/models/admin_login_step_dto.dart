// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_login_step_dto_step.dart';

part 'admin_login_step_dto.g.dart';

@JsonSerializable()
class AdminLoginStepDto {
  const AdminLoginStepDto({required this.step, required this.challengeToken});

  factory AdminLoginStepDto.fromJson(Map<String, Object?> json) =>
      _$AdminLoginStepDtoFromJson(json);

  final AdminLoginStepDtoStep step;
  final String challengeToken;

  Map<String, Object?> toJson() => _$AdminLoginStepDtoToJson(this);
}

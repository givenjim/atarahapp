// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'verification_sent_dto.dart';

part 'register_result_dto.g.dart';

@JsonSerializable()
class RegisterResultDto {
  const RegisterResultDto({required this.verification});

  factory RegisterResultDto.fromJson(Map<String, Object?> json) =>
      _$RegisterResultDtoFromJson(json);

  final VerificationSentDto verification;

  Map<String, Object?> toJson() => _$RegisterResultDtoToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mfa_factor_dto.dart';

part 'security_dto.g.dart';

@JsonSerializable()
class SecurityDto {
  const SecurityDto({
    required this.factors,
    required this.twoStepEnabled,
    required this.hasVerifiedFactor,
    required this.activeSessions,
    required this.deviceCount,
  });

  factory SecurityDto.fromJson(Map<String, Object?> json) =>
      _$SecurityDtoFromJson(json);

  final List<MfaFactorDto> factors;

  /// The member turned two-step sign-in on (new devices need the second step).
  final bool twoStepEnabled;

  /// A verified second factor is enrolled, so two-step can be switched on.
  final bool hasVerifiedFactor;
  final num activeSessions;

  /// Devices that have signed in.
  final num deviceCount;

  Map<String, Object?> toJson() => _$SecurityDtoToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mfa_factor_dto_status.dart';
import 'mfa_factor_dto_type.dart';

part 'mfa_factor_dto.g.dart';

@JsonSerializable()
class MfaFactorDto {
  const MfaFactorDto({
    required this.id,
    required this.type,
    required this.status,
    required this.friendlyName,
    required this.createdAt,
  });

  factory MfaFactorDto.fromJson(Map<String, Object?> json) =>
      _$MfaFactorDtoFromJson(json);

  final String id;
  final MfaFactorDtoType type;
  final MfaFactorDtoStatus status;
  final String? friendlyName;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$MfaFactorDtoToJson(this);
}

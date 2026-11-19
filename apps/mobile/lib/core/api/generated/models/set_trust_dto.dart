// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_trust.dart';

part 'set_trust_dto.g.dart';

@JsonSerializable()
class SetTrustDto {
  const SetTrustDto({
    required this.trust,
    this.reason,
  });
  
  factory SetTrustDto.fromJson(Map<String, Object?> json) => _$SetTrustDtoFromJson(json);
  
  final OpportunityTrust trust;

  /// Why, for the audit trail.
  final String? reason;

  Map<String, Object?> toJson() => _$SetTrustDtoToJson(this);
}

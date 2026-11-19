// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'profile_gap_dto_verdict.dart';
import 'rule_result_dto.dart';

part 'profile_gap_dto.g.dart';

@JsonSerializable()
class ProfileGapDto {
  const ProfileGapDto({
    required this.verdict,
    required this.metCount,
    required this.missingCount,
    required this.unknownCount,
    required this.blockingMissingCount,
    required this.rules,
  });
  
  factory ProfileGapDto.fromJson(Map<String, Object?> json) => _$ProfileGapDtoFromJson(json);
  
  final ProfileGapDtoVerdict verdict;
  final num metCount;
  final num missingCount;
  final num unknownCount;
  final num blockingMissingCount;
  final List<RuleResultDto> rules;

  Map<String, Object?> toJson() => _$ProfileGapDtoToJson(this);
}

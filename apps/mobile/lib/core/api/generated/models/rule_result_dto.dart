// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_rule_type.dart';
import 'rule_fix_dto.dart';
import 'rule_result_dto_state.dart';

part 'rule_result_dto.g.dart';

@JsonSerializable()
class RuleResultDto {
  const RuleResultDto({
    required this.id,
    required this.ruleType,
    required this.label,
    required this.isBlocking,
    required this.state,
    this.detail,
    this.fix,
  });

  factory RuleResultDto.fromJson(Map<String, Object?> json) =>
      _$RuleResultDtoFromJson(json);

  final String id;
  final OpportunityRuleType ruleType;
  final String label;
  final bool isBlocking;
  final RuleResultDtoState state;
  final String? detail;
  final RuleFixDto? fix;

  Map<String, Object?> toJson() => _$RuleResultDtoToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_rule_type.dart';

part 'rule_input_dto.g.dart';

@JsonSerializable()
class RuleInputDto {
  const RuleInputDto({
    required this.ruleType,
    required this.params,
    required this.label,
    this.isBlocking = true,
  });

  factory RuleInputDto.fromJson(Map<String, Object?> json) =>
      _$RuleInputDtoFromJson(json);

  final OpportunityRuleType ruleType;

  /// Validated per rule type.
  final dynamic params;

  /// What the member reads: "At least 3 published projects".
  final String label;
  final bool isBlocking;

  Map<String, Object?> toJson() => _$RuleInputDtoToJson(this);
}

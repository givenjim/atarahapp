// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_rule_type.dart';

part 'admin_rule_dto.g.dart';

@JsonSerializable()
class AdminRuleDto {
  const AdminRuleDto({
    required this.id,
    required this.ruleType,
    required this.params,
    required this.label,
    required this.isBlocking,
    required this.sortOrder,
  });

  factory AdminRuleDto.fromJson(Map<String, Object?> json) =>
      _$AdminRuleDtoFromJson(json);

  final String id;
  final OpportunityRuleType ruleType;
  final dynamic params;
  final String label;
  final bool isBlocking;
  final num sortOrder;

  Map<String, Object?> toJson() => _$AdminRuleDtoToJson(this);
}

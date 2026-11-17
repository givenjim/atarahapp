// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_rule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminRuleDto _$AdminRuleDtoFromJson(Map<String, dynamic> json) => AdminRuleDto(
  id: json['id'] as String,
  ruleType: OpportunityRuleType.fromJson(json['ruleType'] as String),
  params: json['params'],
  label: json['label'] as String,
  isBlocking: json['isBlocking'] as bool,
  sortOrder: json['sortOrder'] as num,
);

Map<String, dynamic> _$AdminRuleDtoToJson(AdminRuleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ruleType': instance.ruleType,
      'params': instance.params,
      'label': instance.label,
      'isBlocking': instance.isBlocking,
      'sortOrder': instance.sortOrder,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_input_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleInputDto _$RuleInputDtoFromJson(Map<String, dynamic> json) => RuleInputDto(
  ruleType: OpportunityRuleType.fromJson(json['ruleType'] as String),
  params: json['params'],
  label: json['label'] as String,
  isBlocking: json['isBlocking'] as bool? ?? true,
);

Map<String, dynamic> _$RuleInputDtoToJson(RuleInputDto instance) =>
    <String, dynamic>{
      'ruleType': instance.ruleType,
      'params': instance.params,
      'label': instance.label,
      'isBlocking': instance.isBlocking,
    };

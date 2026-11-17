// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleResultDto _$RuleResultDtoFromJson(Map<String, dynamic> json) =>
    RuleResultDto(
      id: json['id'] as String,
      ruleType: OpportunityRuleType.fromJson(json['ruleType'] as String),
      label: json['label'] as String,
      isBlocking: json['isBlocking'] as bool,
      state: RuleResultDtoState.fromJson(json['state'] as String),
      detail: json['detail'] as String?,
      fix: json['fix'] == null
          ? null
          : RuleFixDto.fromJson(json['fix'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RuleResultDtoToJson(RuleResultDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ruleType': instance.ruleType,
      'label': instance.label,
      'isBlocking': instance.isBlocking,
      'state': instance.state,
      'detail': instance.detail,
      'fix': instance.fix,
    };

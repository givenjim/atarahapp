// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_type.dart';
import 'rule_input_dto.dart';
import 'update_opportunity_dto_application_method.dart';
import 'work_mode.dart';

part 'update_opportunity_dto.g.dart';

@JsonSerializable()
class UpdateOpportunityDto {
  const UpdateOpportunityDto({
    required this.title,
    required this.providerId,
    required this.type,
    required this.summary,
    required this.about,
    required this.requirements,
    required this.benefits,
    required this.valueMin,
    required this.valueMax,
    required this.valueCurrency,
    required this.valueText,
    required this.deadlineAt,
    required this.countyId,
    required this.workMode,
    required this.applicationMethod,
    required this.applicationUrl,
    required this.applicationEmail,
    required this.sourceUrl,
    required this.disciplineIds,
    required this.rules,
  });
  
  factory UpdateOpportunityDto.fromJson(Map<String, Object?> json) => _$UpdateOpportunityDtoFromJson(json);
  
  final String title;
  final String providerId;
  final OpportunityType type;
  final String summary;
  final String about;
  final List<String> requirements;
  final List<String> benefits;
  final num? valueMin;
  final num? valueMax;
  final String valueCurrency;
  final String? valueText;
  final DateTime? deadlineAt;
  final String? countyId;
  final WorkMode workMode;
  final UpdateOpportunityDtoApplicationMethod applicationMethod;
  final String applicationUrl;
  final String applicationEmail;
  final String sourceUrl;
  final List<String> disciplineIds;
  final List<RuleInputDto> rules;

  Map<String, Object?> toJson() => _$UpdateOpportunityDtoToJson(this);
}

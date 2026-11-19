// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_fields_dto_application_method.dart';
import 'opportunity_type.dart';
import 'rule_input_dto.dart';
import 'work_mode.dart';

part 'opportunity_fields_dto.g.dart';

@JsonSerializable()
class OpportunityFieldsDto {
  const OpportunityFieldsDto({
    required this.title,
    required this.providerId,
    required this.type,
    required this.summary,
    this.about,
    this.requirements,
    this.benefits,
    this.valueMin,
    this.valueMax,
    this.valueCurrency,
    this.valueText,
    this.deadlineAt,
    this.countyId,
    this.workMode,
    this.applicationMethod,
    this.applicationUrl,
    this.applicationEmail,
    this.sourceUrl,
    this.disciplineIds,
    this.rules,
  });
  
  factory OpportunityFieldsDto.fromJson(Map<String, Object?> json) => _$OpportunityFieldsDtoFromJson(json);
  
  final String title;
  final String providerId;
  final OpportunityType type;
  final String summary;
  final String? about;
  final List<String>? requirements;
  final List<String>? benefits;

  /// Smallest amount in major units (KES), e.g. 100000.
  final num? valueMin;
  final num? valueMax;

  /// Defaults to KES when an amount is given.
  final String? valueCurrency;

  /// Shown when there is no plain amount: "Paid stipend".
  final String? valueText;

  /// Null means a rolling deadline.
  final DateTime? deadlineAt;
  final dynamic countyId;
  final WorkMode? workMode;

  /// IN_APP is reserved for Phase 3.
  final OpportunityFieldsDtoApplicationMethod? applicationMethod;

  /// https only.
  final String? applicationUrl;
  final String? applicationEmail;
  final String? sourceUrl;
  final List<String>? disciplineIds;

  /// Replaces every rule when given.
  final List<RuleInputDto>? rules;

  Map<String, Object?> toJson() => _$OpportunityFieldsDtoToJson(this);
}

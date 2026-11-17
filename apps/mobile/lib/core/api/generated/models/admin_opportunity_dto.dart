// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_opportunity_dto_link_status.dart';
import 'admin_provider_dto.dart';
import 'admin_rule_dto.dart';
import 'application_method.dart';
import 'opportunity_status.dart';
import 'opportunity_trust.dart';
import 'opportunity_type.dart';
import 'work_mode.dart';

part 'admin_opportunity_dto.g.dart';

@JsonSerializable()
class AdminOpportunityDto {
  const AdminOpportunityDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.type,
    required this.status,
    required this.trust,
    required this.provider,
    required this.summary,
    required this.about,
    required this.requirements,
    required this.benefits,
    required this.workMode,
    required this.applicationMethod,
    required this.linkStatus,
    required this.disciplineIds,
    required this.rules,
    required this.trackerCount,
    required this.createdAt,
    required this.updatedAt,
    this.valueMin,
    this.valueMax,
    this.valueCurrency,
    this.valueText,
    this.deadlineAt,
    this.countyId,
    this.countyName,
    this.applicationUrl,
    this.applicationEmail,
    this.applicationDomain,
    this.sourceUrl,
    this.featuredUntil,
    this.lastCheckedAt,
    this.publishedAt,
  });

  factory AdminOpportunityDto.fromJson(Map<String, Object?> json) =>
      _$AdminOpportunityDtoFromJson(json);

  final String id;
  final String slug;
  final String title;
  final OpportunityType type;
  final OpportunityStatus status;
  final OpportunityTrust trust;
  final AdminProviderDto provider;
  final String summary;
  final String about;
  final List<String> requirements;
  final List<String> benefits;
  final num? valueMin;
  final num? valueMax;
  final String? valueCurrency;
  final String? valueText;
  final DateTime? deadlineAt;
  final String? countyId;
  final String? countyName;
  final WorkMode workMode;
  final ApplicationMethod applicationMethod;
  final String? applicationUrl;
  final String? applicationEmail;
  final String? applicationDomain;
  final String? sourceUrl;
  final DateTime? featuredUntil;
  final AdminOpportunityDtoLinkStatus linkStatus;
  final DateTime? lastCheckedAt;
  final DateTime? publishedAt;
  final List<String> disciplineIds;
  final List<AdminRuleDto> rules;

  /// Members who saved or are tracking it.
  final num trackerCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$AdminOpportunityDtoToJson(this);
}

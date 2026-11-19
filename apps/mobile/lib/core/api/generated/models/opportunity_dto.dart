// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'application_method.dart';
import 'opportunity_dto_urgency.dart';
import 'opportunity_provider_lite_dto.dart';
import 'opportunity_trust.dart';
import 'opportunity_type.dart';
import 'profile_gap_dto.dart';
import 'tracking_state_dto.dart';
import 'work_mode.dart';

part 'opportunity_dto.g.dart';

@JsonSerializable()
class OpportunityDto {
  const OpportunityDto({
    required this.id,
    required this.slug,
    required this.type,
    required this.title,
    required this.summary,
    required this.trust,
    required this.provider,
    required this.workMode,
    required this.featured,
    required this.saved,
    required this.closed,
    required this.about,
    required this.requirements,
    required this.benefits,
    required this.applicationMethod,
    required this.profileGap,
    required this.shareUrl,
    this.valueLabel,
    this.deadlineAt,
    this.daysLeft,
    this.urgency,
    this.locationLabel,
    this.tracking,
    this.applicationUrl,
    this.applicationEmail,
    this.applicationDomain,
    this.disciplines,
  });
  
  factory OpportunityDto.fromJson(Map<String, Object?> json) => _$OpportunityDtoFromJson(json);
  
  final String id;
  final String slug;
  final OpportunityType type;
  final String title;
  final String summary;
  final OpportunityTrust trust;
  final OpportunityProviderLiteDto provider;

  /// Ready to show: "KES 500,000".
  final String? valueLabel;
  final DateTime? deadlineAt;

  /// Whole days left; null for a rolling deadline.
  final num? daysLeft;

  /// Closing soon: URGENT is 7 days or fewer (Coral), SOON is 8 to 14 (Tangerine).
  final OpportunityDtoUrgency? urgency;
  final WorkMode workMode;

  /// County name, "Remote" or "Hybrid".
  final String? locationLabel;
  final bool featured;

  /// The member has it in their saved list (SAVED or IN_PROGRESS).
  final bool saved;
  final TrackingStateDto? tracking;

  /// The deadline has passed or the listing closed; only tracked items stay visible.
  final bool closed;
  final String about;
  final List<String> requirements;
  final List<String> benefits;
  final ApplicationMethod applicationMethod;

  /// The https address the app opens.
  final String? applicationUrl;
  final String? applicationEmail;

  /// Named in the "Leaving Atarah" modal.
  final String? applicationDomain;

  /// Discipline names.
  final List<String>? disciplines;
  final ProfileGapDto profileGap;
  final String shareUrl;

  Map<String, Object?> toJson() => _$OpportunityDtoToJson(this);
}

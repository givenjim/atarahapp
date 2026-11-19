// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_card_dto_urgency.dart';
import 'opportunity_provider_lite_dto.dart';
import 'opportunity_trust.dart';
import 'opportunity_type.dart';
import 'tracking_state_dto.dart';
import 'work_mode.dart';

part 'opportunity_card_dto.g.dart';

@JsonSerializable()
class OpportunityCardDto {
  const OpportunityCardDto({
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
    this.valueLabel,
    this.deadlineAt,
    this.daysLeft,
    this.urgency,
    this.locationLabel,
    this.tracking,
  });
  
  factory OpportunityCardDto.fromJson(Map<String, Object?> json) => _$OpportunityCardDtoFromJson(json);
  
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
  final OpportunityCardDtoUrgency? urgency;
  final WorkMode workMode;

  /// County name, "Remote" or "Hybrid".
  final String? locationLabel;
  final bool featured;

  /// The member has it in their saved list (SAVED or IN_PROGRESS).
  final bool saved;
  final TrackingStateDto? tracking;

  /// The deadline has passed or the listing closed; only tracked items stay visible.
  final bool closed;

  Map<String, Object?> toJson() => _$OpportunityCardDtoToJson(this);
}

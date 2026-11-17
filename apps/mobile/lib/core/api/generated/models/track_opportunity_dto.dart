// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_outcome.dart';
import 'opportunity_tracking_status.dart';

part 'track_opportunity_dto.g.dart';

@JsonSerializable()
class TrackOpportunityDto {
  const TrackOpportunityDto({required this.status, this.outcome, this.notes});

  factory TrackOpportunityDto.fromJson(Map<String, Object?> json) =>
      _$TrackOpportunityDtoFromJson(json);

  final OpportunityTrackingStatus status;

  /// Only with COMPLETED. Defaults to UNKNOWN.
  final OpportunityOutcome? outcome;
  final String? notes;

  Map<String, Object?> toJson() => _$TrackOpportunityDtoToJson(this);
}

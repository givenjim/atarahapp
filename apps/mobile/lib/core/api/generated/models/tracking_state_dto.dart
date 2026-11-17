// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_outcome.dart';
import 'opportunity_tracking_status.dart';

part 'tracking_state_dto.g.dart';

@JsonSerializable()
class TrackingStateDto {
  const TrackingStateDto({
    required this.status,
    this.savedAt,
    this.appliedAt,
    this.completedAt,
    this.outcome,
  });

  factory TrackingStateDto.fromJson(Map<String, Object?> json) =>
      _$TrackingStateDtoFromJson(json);

  final OpportunityTrackingStatus status;
  final DateTime? savedAt;
  final DateTime? appliedAt;
  final DateTime? completedAt;
  final OpportunityOutcome? outcome;

  Map<String, Object?> toJson() => _$TrackingStateDtoToJson(this);
}

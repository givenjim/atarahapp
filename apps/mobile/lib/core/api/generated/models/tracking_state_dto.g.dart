// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackingStateDto _$TrackingStateDtoFromJson(Map<String, dynamic> json) =>
    TrackingStateDto(
      status: OpportunityTrackingStatus.fromJson(json['status'] as String),
      savedAt: json['savedAt'] == null
          ? null
          : DateTime.parse(json['savedAt'] as String),
      appliedAt: json['appliedAt'] == null
          ? null
          : DateTime.parse(json['appliedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      outcome: json['outcome'] == null
          ? null
          : OpportunityOutcome.fromJson(json['outcome'] as String),
    );

Map<String, dynamic> _$TrackingStateDtoToJson(TrackingStateDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'savedAt': instance.savedAt?.toIso8601String(),
      'appliedAt': instance.appliedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'outcome': instance.outcome,
    };

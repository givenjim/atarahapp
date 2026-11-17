// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_opportunity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackOpportunityDto _$TrackOpportunityDtoFromJson(Map<String, dynamic> json) =>
    TrackOpportunityDto(
      status: OpportunityTrackingStatus.fromJson(json['status'] as String),
      outcome: json['outcome'] == null
          ? null
          : OpportunityOutcome.fromJson(json['outcome'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TrackOpportunityDtoToJson(
  TrackOpportunityDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'outcome': instance.outcome,
  'notes': instance.notes,
};

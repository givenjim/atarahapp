// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardDto _$DashboardDtoFromJson(Map<String, dynamic> json) => DashboardDto(
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  queues: (json['queues'] as List<dynamic>)
      .map((e) => AttentionQueueDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  counts: DashboardCountsDto.fromJson(json['counts'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DashboardDtoToJson(DashboardDto instance) =>
    <String, dynamic>{
      'generatedAt': instance.generatedAt.toIso8601String(),
      'queues': instance.queues,
      'counts': instance.counts,
    };

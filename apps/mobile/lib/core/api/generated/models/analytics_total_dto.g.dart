// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_total_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsTotalDto _$AnalyticsTotalDtoFromJson(Map<String, dynamic> json) =>
    AnalyticsTotalDto(
      name: json['name'] as String,
      events: json['events'] as num,
      activeMemberDays: json['activeMemberDays'] as num,
    );

Map<String, dynamic> _$AnalyticsTotalDtoToJson(AnalyticsTotalDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'events': instance.events,
      'activeMemberDays': instance.activeMemberDays,
    };

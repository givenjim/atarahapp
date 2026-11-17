// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_point_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsPointDto _$AnalyticsPointDtoFromJson(Map<String, dynamic> json) =>
    AnalyticsPointDto(
      day: json['day'] as String,
      name: json['name'] as String,
      events: json['events'] as num,
      actors: json['actors'] as num,
    );

Map<String, dynamic> _$AnalyticsPointDtoToJson(AnalyticsPointDto instance) =>
    <String, dynamic>{
      'day': instance.day,
      'name': instance.name,
      'events': instance.events,
      'actors': instance.actors,
    };

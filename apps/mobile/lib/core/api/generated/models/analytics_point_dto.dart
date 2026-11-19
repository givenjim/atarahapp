// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'analytics_point_dto.g.dart';

@JsonSerializable()
class AnalyticsPointDto {
  const AnalyticsPointDto({
    required this.day,
    required this.name,
    required this.events,
    required this.actors,
  });
  
  factory AnalyticsPointDto.fromJson(Map<String, Object?> json) => _$AnalyticsPointDtoFromJson(json);
  
  final String day;
  final String name;
  final num events;

  /// Distinct members that day (privacy-safe hashes, never identities).
  final num actors;

  Map<String, Object?> toJson() => _$AnalyticsPointDtoToJson(this);
}

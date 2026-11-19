// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'analytics_total_dto.g.dart';

@JsonSerializable()
class AnalyticsTotalDto {
  const AnalyticsTotalDto({
    required this.name,
    required this.events,
    required this.activeMemberDays,
  });
  
  factory AnalyticsTotalDto.fromJson(Map<String, Object?> json) => _$AnalyticsTotalDtoFromJson(json);
  
  final String name;
  final num events;

  /// Sum of each day's distinct members.
  final num activeMemberDays;

  Map<String, Object?> toJson() => _$AnalyticsTotalDtoToJson(this);
}

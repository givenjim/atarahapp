// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'analytics_point_dto.dart';
import 'analytics_total_dto.dart';

part 'analytics_series_dto.g.dart';

@JsonSerializable()
class AnalyticsSeriesDto {
  const AnalyticsSeriesDto({
    required this.from,
    required this.to,
    required this.series,
    required this.totals,
  });

  factory AnalyticsSeriesDto.fromJson(Map<String, Object?> json) =>
      _$AnalyticsSeriesDtoFromJson(json);

  final String from;
  final String to;
  final List<AnalyticsPointDto> series;
  final List<AnalyticsTotalDto> totals;

  Map<String, Object?> toJson() => _$AnalyticsSeriesDtoToJson(this);
}

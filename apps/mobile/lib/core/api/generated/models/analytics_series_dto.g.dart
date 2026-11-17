// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_series_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsSeriesDto _$AnalyticsSeriesDtoFromJson(Map<String, dynamic> json) =>
    AnalyticsSeriesDto(
      from: json['from'] as String,
      to: json['to'] as String,
      series: (json['series'] as List<dynamic>)
          .map((e) => AnalyticsPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totals: (json['totals'] as List<dynamic>)
          .map((e) => AnalyticsTotalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalyticsSeriesDtoToJson(AnalyticsSeriesDto instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'series': instance.series,
      'totals': instance.totals,
    };

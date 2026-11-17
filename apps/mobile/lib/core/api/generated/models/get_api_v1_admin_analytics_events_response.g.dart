// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_analytics_events_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminAnalyticsEventsResponse
_$GetApiV1AdminAnalyticsEventsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminAnalyticsEventsResponse(
      data: AnalyticsSeriesDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminAnalyticsEventsResponseToJson(
  GetApiV1AdminAnalyticsEventsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

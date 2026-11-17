// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_learning_analytics_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminLearningAnalyticsResponse
_$GetApiV1AdminLearningAnalyticsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminLearningAnalyticsResponse(
      data: LearningAnalyticsDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminLearningAnalyticsResponseToJson(
  GetApiV1AdminLearningAnalyticsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

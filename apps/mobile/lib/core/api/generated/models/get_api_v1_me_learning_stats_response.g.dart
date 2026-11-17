// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_learning_stats_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeLearningStatsResponse _$GetApiV1MeLearningStatsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeLearningStatsResponse(
  data: LearningStatsDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeLearningStatsResponseToJson(
  GetApiV1MeLearningStatsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

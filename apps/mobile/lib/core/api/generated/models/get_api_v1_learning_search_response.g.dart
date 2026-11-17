// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_learning_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LearningSearchResponse _$GetApiV1LearningSearchResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LearningSearchResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => LearningCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LearningSearchResponseToJson(
  GetApiV1LearningSearchResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

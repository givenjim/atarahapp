// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1SearchResponse _$GetApiV1SearchResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1SearchResponse(
  data: SearchResultDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1SearchResponseToJson(
  GetApiV1SearchResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

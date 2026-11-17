// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_saved_counts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeSavedCountsResponse _$GetApiV1MeSavedCountsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeSavedCountsResponse(
  data: SavedCountsDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeSavedCountsResponseToJson(
  GetApiV1MeSavedCountsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

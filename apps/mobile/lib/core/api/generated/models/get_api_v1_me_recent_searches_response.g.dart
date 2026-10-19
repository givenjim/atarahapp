// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_recent_searches_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeRecentSearchesResponse _$GetApiV1MeRecentSearchesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeRecentSearchesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => RecentSearchDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeRecentSearchesResponseToJson(
  GetApiV1MeRecentSearchesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

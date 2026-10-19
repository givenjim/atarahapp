// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_recent_searches_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeRecentSearchesResponse _$PostApiV1MeRecentSearchesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeRecentSearchesResponse(
  data: RecentSearchDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeRecentSearchesResponseToJson(
  PostApiV1MeRecentSearchesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

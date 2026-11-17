// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_community_feed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CommunityFeedResponse _$GetApiV1CommunityFeedResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1CommunityFeedResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => PostViewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1CommunityFeedResponseToJson(
  GetApiV1CommunityFeedResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

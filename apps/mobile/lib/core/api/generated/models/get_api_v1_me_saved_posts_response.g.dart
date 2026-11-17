// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_saved_posts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeSavedPostsResponse _$GetApiV1MeSavedPostsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeSavedPostsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => PostViewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeSavedPostsResponseToJson(
  GetApiV1MeSavedPostsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

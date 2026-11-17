// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_groups_ref_posts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1GroupsRefPostsResponse _$GetApiV1GroupsRefPostsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1GroupsRefPostsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => PostViewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1GroupsRefPostsResponseToJson(
  GetApiV1GroupsRefPostsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

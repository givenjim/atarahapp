// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_groups_ref_posts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1GroupsRefPostsResponse _$PostApiV1GroupsRefPostsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1GroupsRefPostsResponse(
  data: PostViewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1GroupsRefPostsResponseToJson(
  PostApiV1GroupsRefPostsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_posts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1PostsResponse _$PostApiV1PostsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1PostsResponse(
  data: PostViewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1PostsResponseToJson(
  PostApiV1PostsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_posts_id_comments_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1PostsIdCommentsResponse _$PostApiV1PostsIdCommentsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1PostsIdCommentsResponse(
  data: CommentViewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1PostsIdCommentsResponseToJson(
  PostApiV1PostsIdCommentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

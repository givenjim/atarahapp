// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_posts_id_comments_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1PostsIdCommentsResponse _$GetApiV1PostsIdCommentsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1PostsIdCommentsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CommentViewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1PostsIdCommentsResponseToJson(
  GetApiV1PostsIdCommentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

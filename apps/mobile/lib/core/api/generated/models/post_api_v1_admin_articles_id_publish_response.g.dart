// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_articles_id_publish_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminArticlesIdPublishResponse
_$PostApiV1AdminArticlesIdPublishResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminArticlesIdPublishResponse(
      data: AdminArticleDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminArticlesIdPublishResponseToJson(
  PostApiV1AdminArticlesIdPublishResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

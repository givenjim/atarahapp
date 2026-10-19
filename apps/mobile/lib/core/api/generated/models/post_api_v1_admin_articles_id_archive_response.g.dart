// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_articles_id_archive_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminArticlesIdArchiveResponse
_$PostApiV1AdminArticlesIdArchiveResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminArticlesIdArchiveResponse(
      data: AdminArticleDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminArticlesIdArchiveResponseToJson(
  PostApiV1AdminArticlesIdArchiveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

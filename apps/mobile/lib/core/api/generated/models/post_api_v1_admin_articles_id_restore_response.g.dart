// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_articles_id_restore_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminArticlesIdRestoreResponse
_$PostApiV1AdminArticlesIdRestoreResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminArticlesIdRestoreResponse(
      data: AdminArticleDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminArticlesIdRestoreResponseToJson(
  PostApiV1AdminArticlesIdRestoreResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

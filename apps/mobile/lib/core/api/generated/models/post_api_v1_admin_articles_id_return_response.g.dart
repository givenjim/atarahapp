// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_articles_id_return_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminArticlesIdReturnResponse
_$PostApiV1AdminArticlesIdReturnResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminArticlesIdReturnResponse(
      data: AdminArticleDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminArticlesIdReturnResponseToJson(
  PostApiV1AdminArticlesIdReturnResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

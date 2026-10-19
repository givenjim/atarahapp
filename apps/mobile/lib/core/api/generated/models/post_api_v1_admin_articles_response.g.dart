// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_articles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminArticlesResponse _$PostApiV1AdminArticlesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminArticlesResponse(
  data: AdminArticleDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminArticlesResponseToJson(
  PostApiV1AdminArticlesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

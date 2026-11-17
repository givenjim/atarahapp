// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_help_articles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminHelpArticlesResponse _$PostApiV1AdminHelpArticlesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminHelpArticlesResponse(
  data: AdminHelpArticleDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminHelpArticlesResponseToJson(
  PostApiV1AdminHelpArticlesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

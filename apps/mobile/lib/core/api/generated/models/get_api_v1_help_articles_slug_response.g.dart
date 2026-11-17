// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_help_articles_slug_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1HelpArticlesSlugResponse _$GetApiV1HelpArticlesSlugResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1HelpArticlesSlugResponse(
  data: HelpArticleDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1HelpArticlesSlugResponseToJson(
  GetApiV1HelpArticlesSlugResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

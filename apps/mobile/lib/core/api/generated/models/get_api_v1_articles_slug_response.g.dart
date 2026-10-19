// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_articles_slug_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1ArticlesSlugResponse _$GetApiV1ArticlesSlugResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1ArticlesSlugResponse(
  data: ArticleDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1ArticlesSlugResponseToJson(
  GetApiV1ArticlesSlugResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

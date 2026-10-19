// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_articles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminArticlesResponse _$GetApiV1AdminArticlesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminArticlesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminArticleListItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminArticlesResponseToJson(
  GetApiV1AdminArticlesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

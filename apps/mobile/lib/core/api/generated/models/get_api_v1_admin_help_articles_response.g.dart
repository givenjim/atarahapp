// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_help_articles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminHelpArticlesResponse _$GetApiV1AdminHelpArticlesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminHelpArticlesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminHelpArticleDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminHelpArticlesResponseToJson(
  GetApiV1AdminHelpArticlesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

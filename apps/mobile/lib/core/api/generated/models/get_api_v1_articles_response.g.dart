// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_articles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1ArticlesResponse _$GetApiV1ArticlesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1ArticlesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ArticleCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1ArticlesResponseToJson(
  GetApiV1ArticlesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

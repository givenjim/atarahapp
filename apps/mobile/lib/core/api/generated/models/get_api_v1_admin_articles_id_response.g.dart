// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_articles_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminArticlesIdResponse _$GetApiV1AdminArticlesIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminArticlesIdResponse(
  data: AdminArticleDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminArticlesIdResponseToJson(
  GetApiV1AdminArticlesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

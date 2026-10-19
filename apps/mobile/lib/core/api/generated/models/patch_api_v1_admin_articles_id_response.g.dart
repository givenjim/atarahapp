// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_articles_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminArticlesIdResponse _$PatchApiV1AdminArticlesIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminArticlesIdResponse(
  data: AdminArticleDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminArticlesIdResponseToJson(
  PatchApiV1AdminArticlesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_help_articles_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminHelpArticlesIdResponse
_$PatchApiV1AdminHelpArticlesIdResponseFromJson(Map<String, dynamic> json) =>
    PatchApiV1AdminHelpArticlesIdResponse(
      data: AdminHelpArticleDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PatchApiV1AdminHelpArticlesIdResponseToJson(
  PatchApiV1AdminHelpArticlesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_help_articles_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminHelpArticlesIdResponse
_$GetApiV1AdminHelpArticlesIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminHelpArticlesIdResponse(
      data: AdminHelpArticleDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminHelpArticlesIdResponseToJson(
  GetApiV1AdminHelpArticlesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_articles_id_submit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminArticlesIdSubmitResponse
_$PostApiV1AdminArticlesIdSubmitResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminArticlesIdSubmitResponse(
      data: AdminArticleDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminArticlesIdSubmitResponseToJson(
  PostApiV1AdminArticlesIdSubmitResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

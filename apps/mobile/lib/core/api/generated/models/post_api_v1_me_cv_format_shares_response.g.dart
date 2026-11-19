// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_cv_format_shares_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeCvFormatSharesResponse _$PostApiV1MeCvFormatSharesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeCvFormatSharesResponse(
  data: CvShareCreatedDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeCvFormatSharesResponseToJson(
  PostApiV1MeCvFormatSharesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

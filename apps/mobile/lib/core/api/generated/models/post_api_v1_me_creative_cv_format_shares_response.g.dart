// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_creative_cv_format_shares_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeCreativeCvFormatSharesResponse
_$PostApiV1MeCreativeCvFormatSharesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeCreativeCvFormatSharesResponse(
  data: CvShareCreatedDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeCreativeCvFormatSharesResponseToJson(
  PostApiV1MeCreativeCvFormatSharesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

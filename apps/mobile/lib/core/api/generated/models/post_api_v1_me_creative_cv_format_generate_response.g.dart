// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_creative_cv_format_generate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeCreativeCvFormatGenerateResponse
_$PostApiV1MeCreativeCvFormatGenerateResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeCreativeCvFormatGenerateResponse(
  data: CvRenderDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeCreativeCvFormatGenerateResponseToJson(
  PostApiV1MeCreativeCvFormatGenerateResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

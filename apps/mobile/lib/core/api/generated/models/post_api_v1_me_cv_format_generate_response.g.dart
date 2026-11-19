// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_cv_format_generate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeCvFormatGenerateResponse
_$PostApiV1MeCvFormatGenerateResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeCvFormatGenerateResponse(
      data: CvRenderDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeCvFormatGenerateResponseToJson(
  PostApiV1MeCvFormatGenerateResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

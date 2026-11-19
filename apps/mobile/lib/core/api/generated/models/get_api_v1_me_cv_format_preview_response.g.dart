// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_cv_format_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCvFormatPreviewResponse _$GetApiV1MeCvFormatPreviewResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeCvFormatPreviewResponse(
  data: CvPreviewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeCvFormatPreviewResponseToJson(
  GetApiV1MeCvFormatPreviewResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

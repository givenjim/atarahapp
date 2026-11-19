// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_creative_cv_format_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCreativeCvFormatPreviewResponse
_$GetApiV1MeCreativeCvFormatPreviewResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeCreativeCvFormatPreviewResponse(
  data: CvPreviewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeCreativeCvFormatPreviewResponseToJson(
  GetApiV1MeCreativeCvFormatPreviewResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_creative_cv_format_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCreativeCvFormatResponse _$GetApiV1MeCreativeCvFormatResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeCreativeCvFormatResponse(
  data: CvStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeCreativeCvFormatResponseToJson(
  GetApiV1MeCreativeCvFormatResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

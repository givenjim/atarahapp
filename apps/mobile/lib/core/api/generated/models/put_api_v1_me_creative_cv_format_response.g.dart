// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_me_creative_cv_format_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1MeCreativeCvFormatResponse _$PutApiV1MeCreativeCvFormatResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1MeCreativeCvFormatResponse(
  data: CvStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1MeCreativeCvFormatResponseToJson(
  PutApiV1MeCreativeCvFormatResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

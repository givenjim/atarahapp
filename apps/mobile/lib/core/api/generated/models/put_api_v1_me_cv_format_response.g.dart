// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_me_cv_format_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1MeCvFormatResponse _$PutApiV1MeCvFormatResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1MeCvFormatResponse(
  data: CvStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1MeCvFormatResponseToJson(
  PutApiV1MeCvFormatResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

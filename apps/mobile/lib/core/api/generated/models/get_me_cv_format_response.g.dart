// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_me_cv_format_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetMeCvFormatResponse _$GetMeCvFormatResponseFromJson(
  Map<String, dynamic> json,
) => GetMeCvFormatResponse(
  data: CvStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetMeCvFormatResponseToJson(
  GetMeCvFormatResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

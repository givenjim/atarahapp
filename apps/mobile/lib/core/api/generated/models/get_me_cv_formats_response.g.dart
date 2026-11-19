// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_me_cv_formats_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetMeCvFormatsResponse _$GetMeCvFormatsResponseFromJson(
  Map<String, dynamic> json,
) => GetMeCvFormatsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CvFormatInfoDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetMeCvFormatsResponseToJson(
  GetMeCvFormatsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

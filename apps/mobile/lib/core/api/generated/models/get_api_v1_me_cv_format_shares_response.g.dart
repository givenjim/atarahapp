// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_cv_format_shares_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCvFormatSharesResponse _$GetApiV1MeCvFormatSharesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeCvFormatSharesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CvShareDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeCvFormatSharesResponseToJson(
  GetApiV1MeCvFormatSharesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

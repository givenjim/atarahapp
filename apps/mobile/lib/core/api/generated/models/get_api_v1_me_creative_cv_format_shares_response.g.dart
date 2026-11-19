// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_creative_cv_format_shares_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCreativeCvFormatSharesResponse
_$GetApiV1MeCreativeCvFormatSharesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MeCreativeCvFormatSharesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => CvShareDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MeCreativeCvFormatSharesResponseToJson(
  GetApiV1MeCreativeCvFormatSharesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

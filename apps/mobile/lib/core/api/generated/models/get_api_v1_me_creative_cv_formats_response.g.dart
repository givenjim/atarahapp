// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_creative_cv_formats_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCreativeCvFormatsResponse
_$GetApiV1MeCreativeCvFormatsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MeCreativeCvFormatsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => CvFormatInfoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MeCreativeCvFormatsResponseToJson(
  GetApiV1MeCreativeCvFormatsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

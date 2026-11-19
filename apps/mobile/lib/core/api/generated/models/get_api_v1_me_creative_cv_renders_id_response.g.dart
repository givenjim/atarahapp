// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_creative_cv_renders_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCreativeCvRendersIdResponse
_$GetApiV1MeCreativeCvRendersIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MeCreativeCvRendersIdResponse(
      data: CvRenderDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MeCreativeCvRendersIdResponseToJson(
  GetApiV1MeCreativeCvRendersIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

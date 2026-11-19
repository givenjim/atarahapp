// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_cv_renders_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeCvRendersIdResponse _$GetApiV1MeCvRendersIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeCvRendersIdResponse(
  data: CvRenderDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeCvRendersIdResponseToJson(
  GetApiV1MeCvRendersIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

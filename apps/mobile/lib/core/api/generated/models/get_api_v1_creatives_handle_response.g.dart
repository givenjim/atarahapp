// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_handle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesHandleResponse _$GetApiV1CreativesHandleResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1CreativesHandleResponse(
  data: PublicProfileDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1CreativesHandleResponseToJson(
  GetApiV1CreativesHandleResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

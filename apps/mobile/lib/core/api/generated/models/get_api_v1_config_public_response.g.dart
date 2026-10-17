// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_config_public_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1ConfigPublicResponse _$GetApiV1ConfigPublicResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1ConfigPublicResponse(
  data: PublicConfigDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1ConfigPublicResponseToJson(
  GetApiV1ConfigPublicResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

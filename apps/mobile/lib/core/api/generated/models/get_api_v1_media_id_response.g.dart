// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_media_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MediaIdResponse _$GetApiV1MediaIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MediaIdResponse(
  data: MediaAssetDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MediaIdResponseToJson(
  GetApiV1MediaIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

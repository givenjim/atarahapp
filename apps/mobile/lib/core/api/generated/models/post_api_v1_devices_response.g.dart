// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_devices_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1DevicesResponse _$PostApiV1DevicesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1DevicesResponse(
  data: DeviceDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1DevicesResponseToJson(
  PostApiV1DevicesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

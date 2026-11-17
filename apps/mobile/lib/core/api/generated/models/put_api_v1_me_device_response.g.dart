// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_me_device_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1MeDeviceResponse _$PutApiV1MeDeviceResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1MeDeviceResponse(
  data: DeviceRegisteredDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1MeDeviceResponseToJson(
  PutApiV1MeDeviceResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

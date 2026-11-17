// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_session_device_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterSessionDeviceDto _$RegisterSessionDeviceDtoFromJson(
  Map<String, dynamic> json,
) => RegisterSessionDeviceDto(
  deviceHash: json['deviceHash'] as String,
  name: json['name'] as String,
  platform: RegisterSessionDeviceDtoPlatform.fromJson(
    json['platform'] as String,
  ),
);

Map<String, dynamic> _$RegisterSessionDeviceDtoToJson(
  RegisterSessionDeviceDto instance,
) => <String, dynamic>{
  'deviceHash': instance.deviceHash,
  'name': instance.name,
  'platform': instance.platform,
};

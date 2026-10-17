// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterDeviceDto _$RegisterDeviceDtoFromJson(Map<String, dynamic> json) =>
    RegisterDeviceDto(
      token: json['token'] as String,
      platform: RegisterDeviceDtoPlatform.fromJson(json['platform'] as String),
      appVersion: json['appVersion'] as String?,
    );

Map<String, dynamic> _$RegisterDeviceDtoToJson(RegisterDeviceDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registered_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceRegisteredDto _$DeviceRegisteredDtoFromJson(Map<String, dynamic> json) =>
    DeviceRegisteredDto(
      newDevice: json['newDevice'] as bool,
      verified: json['verified'] as bool,
    );

Map<String, dynamic> _$DeviceRegisteredDtoToJson(
  DeviceRegisteredDto instance,
) => <String, dynamic>{
  'newDevice': instance.newDevice,
  'verified': instance.verified,
};

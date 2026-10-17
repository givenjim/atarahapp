// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyDto _$VerifyDtoFromJson(Map<String, dynamic> json) => VerifyDto(
  identifier: json['identifier'] as String,
  code: json['code'] as String,
  client: json['client'] == null
      ? null
      : VerifyDtoClient.fromJson(json['client'] as String),
  deviceName: json['deviceName'] as String?,
);

Map<String, dynamic> _$VerifyDtoToJson(VerifyDto instance) => <String, dynamic>{
  'identifier': instance.identifier,
  'code': instance.code,
  'client': instance.client,
  'deviceName': instance.deviceName,
};

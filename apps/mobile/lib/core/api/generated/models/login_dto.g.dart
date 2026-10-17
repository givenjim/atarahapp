// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => LoginDto(
  identifier: json['identifier'] as String,
  password: json['password'] as String,
  client: LoginDtoClient.fromJson(json['client'] as String),
  deviceName: json['deviceName'] as String?,
);

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
  'identifier': instance.identifier,
  'password': instance.password,
  'client': instance.client,
  'deviceName': instance.deviceName,
};

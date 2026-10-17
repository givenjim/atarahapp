// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterDto _$RegisterDtoFromJson(Map<String, dynamic> json) => RegisterDto(
  fullName: json['fullName'] as String,
  identifier: json['identifier'] as String,
  password: json['password'] as String,
  consent: ConsentDto.fromJson(json['consent'] as Map<String, dynamic>),
  client: json['client'] == null
      ? null
      : RegisterDtoClient.fromJson(json['client'] as String),
);

Map<String, dynamic> _$RegisterDtoToJson(RegisterDto instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'identifier': instance.identifier,
      'password': instance.password,
      'consent': instance.consent,
      'client': instance.client,
    };

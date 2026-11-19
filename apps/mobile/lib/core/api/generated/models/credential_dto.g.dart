// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialDto _$CredentialDtoFromJson(Map<String, dynamic> json) =>
    CredentialDto(
      title: json['title'] as String,
      issuer: json['issuer'] as String?,
      year: json['year'] as num?,
    );

Map<String, dynamic> _$CredentialDtoToJson(CredentialDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'issuer': instance.issuer,
      'year': instance.year,
    };

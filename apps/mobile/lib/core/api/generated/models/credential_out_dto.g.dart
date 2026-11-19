// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_out_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialOutDto _$CredentialOutDtoFromJson(Map<String, dynamic> json) =>
    CredentialOutDto(
      title: json['title'] as String,
      issuer: json['issuer'] as String?,
      year: json['year'] as num?,
    );

Map<String, dynamic> _$CredentialOutDtoToJson(CredentialOutDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'issuer': instance.issuer,
      'year': instance.year,
    };

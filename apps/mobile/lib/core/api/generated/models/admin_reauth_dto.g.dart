// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reauth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminReauthDto _$AdminReauthDtoFromJson(Map<String, dynamic> json) =>
    AdminReauthDto(
      password: json['password'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$AdminReauthDtoToJson(AdminReauthDto instance) =>
    <String, dynamic>{'password': instance.password, 'code': instance.code};

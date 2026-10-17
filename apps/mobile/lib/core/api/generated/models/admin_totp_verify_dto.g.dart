// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_totp_verify_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTotpVerifyDto _$AdminTotpVerifyDtoFromJson(Map<String, dynamic> json) =>
    AdminTotpVerifyDto(
      challengeToken: json['challengeToken'] as String,
      code: json['code'] as String?,
      recoveryCode: json['recoveryCode'] as String?,
    );

Map<String, dynamic> _$AdminTotpVerifyDtoToJson(AdminTotpVerifyDto instance) =>
    <String, dynamic>{
      'challengeToken': instance.challengeToken,
      'code': instance.code,
      'recoveryCode': instance.recoveryCode,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_setup_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TotpSetupDto _$TotpSetupDtoFromJson(Map<String, dynamic> json) => TotpSetupDto(
  secret: json['secret'] as String,
  otpauthUrl: json['otpauthUrl'] as String,
);

Map<String, dynamic> _$TotpSetupDtoToJson(TotpSetupDto instance) =>
    <String, dynamic>{
      'secret': instance.secret,
      'otpauthUrl': instance.otpauthUrl,
    };

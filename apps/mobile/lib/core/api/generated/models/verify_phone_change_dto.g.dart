// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_phone_change_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyPhoneChangeDto _$VerifyPhoneChangeDtoFromJson(
  Map<String, dynamic> json,
) => VerifyPhoneChangeDto(
  phone: json['phone'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$VerifyPhoneChangeDtoToJson(
  VerifyPhoneChangeDto instance,
) => <String, dynamic>{'phone': instance.phone, 'code': instance.code};

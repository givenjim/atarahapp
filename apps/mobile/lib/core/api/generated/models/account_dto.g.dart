// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountDto _$AccountDtoFromJson(Map<String, dynamic> json) => AccountDto(
  fullName: json['fullName'] as String,
  emailVerified: json['emailVerified'] as bool,
  phoneVerified: json['phoneVerified'] as bool,
  handle: json['handle'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  pendingEmail: json['pendingEmail'] as String?,
  pendingPhone: json['pendingPhone'] as String?,
);

Map<String, dynamic> _$AccountDtoToJson(AccountDto instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'handle': instance.handle,
      'email': instance.email,
      'emailVerified': instance.emailVerified,
      'phone': instance.phone,
      'phoneVerified': instance.phoneVerified,
      'pendingEmail': instance.pendingEmail,
      'pendingPhone': instance.pendingPhone,
    };

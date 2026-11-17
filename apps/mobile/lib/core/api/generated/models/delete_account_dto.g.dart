// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteAccountDto _$DeleteAccountDtoFromJson(Map<String, dynamic> json) =>
    DeleteAccountDto(
      confirm: json['confirm'] as String,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$DeleteAccountDtoToJson(DeleteAccountDto instance) =>
    <String, dynamic>{
      'confirm': instance.confirm,
      'password': instance.password,
    };

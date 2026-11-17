// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_provider_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyProviderDto _$VerifyProviderDtoFromJson(Map<String, dynamic> json) =>
    VerifyProviderDto(
      status: VerifyProviderDtoStatus.fromJson(json['status'] as String),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$VerifyProviderDtoToJson(VerifyProviderDto instance) =>
    <String, dynamic>{'status': instance.status, 'reason': instance.reason};

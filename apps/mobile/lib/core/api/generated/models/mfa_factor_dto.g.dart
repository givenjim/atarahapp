// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_factor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaFactorDto _$MfaFactorDtoFromJson(Map<String, dynamic> json) => MfaFactorDto(
  id: json['id'] as String,
  type: MfaFactorDtoType.fromJson(json['type'] as String),
  status: MfaFactorDtoStatus.fromJson(json['status'] as String),
  friendlyName: json['friendlyName'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MfaFactorDtoToJson(MfaFactorDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'friendlyName': instance.friendlyName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

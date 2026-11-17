// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_trust_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetTrustDto _$SetTrustDtoFromJson(Map<String, dynamic> json) => SetTrustDto(
  trust: OpportunityTrust.fromJson(json['trust'] as String),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$SetTrustDtoToJson(SetTrustDto instance) =>
    <String, dynamic>{'trust': instance.trust, 'reason': instance.reason};

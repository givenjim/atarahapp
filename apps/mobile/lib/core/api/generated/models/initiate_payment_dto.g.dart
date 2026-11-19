// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initiate_payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitiatePaymentDto _$InitiatePaymentDtoFromJson(Map<String, dynamic> json) =>
    InitiatePaymentDto(
      purpose: InitiatePaymentDtoPurpose.fromJson(json['purpose'] as String),
      method: InitiatePaymentDtoMethod.fromJson(json['method'] as String),
      referenceId: json['referenceId'] as String?,
      phone: json['phone'] as String?,
      sandboxAmountMinor: json['sandboxAmountMinor'] as num?,
    );

Map<String, dynamic> _$InitiatePaymentDtoToJson(InitiatePaymentDto instance) =>
    <String, dynamic>{
      'purpose': instance.purpose,
      'referenceId': instance.referenceId,
      'method': instance.method,
      'phone': instance.phone,
      'sandboxAmountMinor': instance.sandboxAmountMinor,
    };

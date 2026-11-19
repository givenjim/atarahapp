// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminPaymentDto _$AdminPaymentDtoFromJson(Map<String, dynamic> json) =>
    AdminPaymentDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: AdminPaymentDtoStatus.fromJson(json['status'] as String),
      purpose: AdminPaymentDtoPurpose.fromJson(json['purpose'] as String),
      method: AdminPaymentDtoMethod.fromJson(json['method'] as String),
      provider: AdminPaymentDtoProvider.fromJson(json['provider'] as String),
      amountMinor: json['amountMinor'] as num,
      refundedMinor: json['refundedMinor'] as num,
      currency: json['currency'] as String,
      receiptNumber: json['receiptNumber'] as String?,
      failureCode: json['failureCode'] as String?,
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      payer: AdminPayerDto.fromJson(json['payer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdminPaymentDtoToJson(AdminPaymentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status,
      'purpose': instance.purpose,
      'method': instance.method,
      'provider': instance.provider,
      'amountMinor': instance.amountMinor,
      'refundedMinor': instance.refundedMinor,
      'currency': instance.currency,
      'receiptNumber': instance.receiptNumber,
      'failureCode': instance.failureCode,
      'referenceType': instance.referenceType,
      'referenceId': instance.referenceId,
      'payer': instance.payer,
    };

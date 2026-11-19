// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentDto _$PaymentDtoFromJson(Map<String, dynamic> json) => PaymentDto(
  id: json['id'] as String,
  status: PaymentDtoStatus.fromJson(json['status'] as String),
  purpose: PaymentDtoPurpose.fromJson(json['purpose'] as String),
  method: PaymentDtoMethod.fromJson(json['method'] as String),
  amountMinor: json['amountMinor'] as num,
  currency: json['currency'] as String,
  description: json['description'] as String?,
  referenceType: json['referenceType'] as String?,
  referenceId: json['referenceId'] as String?,
  receiptNumber: json['receiptNumber'] as String?,
  failureCode: json['failureCode'] as String?,
  failureReason: json['failureReason'] as String?,
  refundedMinor: json['refundedMinor'] as num,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  timedOut: json['timedOut'] as bool,
  pollAfterSeconds: json['pollAfterSeconds'] as num,
  action: json['action'] == null
      ? null
      : PaymentActionDto.fromJson(json['action'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaymentDtoToJson(PaymentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'purpose': instance.purpose,
      'method': instance.method,
      'amountMinor': instance.amountMinor,
      'currency': instance.currency,
      'description': instance.description,
      'referenceType': instance.referenceType,
      'referenceId': instance.referenceId,
      'receiptNumber': instance.receiptNumber,
      'failureCode': instance.failureCode,
      'failureReason': instance.failureReason,
      'refundedMinor': instance.refundedMinor,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'timedOut': instance.timedOut,
      'pollAfterSeconds': instance.pollAfterSeconds,
      'action': instance.action,
    };

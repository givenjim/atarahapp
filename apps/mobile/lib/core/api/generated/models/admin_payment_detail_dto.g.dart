// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_payment_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminPaymentDetailDto _$AdminPaymentDetailDtoFromJson(
  Map<String, dynamic> json,
) => AdminPaymentDetailDto(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  status: AdminPaymentDetailDtoStatus.fromJson(json['status'] as String),
  purpose: AdminPaymentDetailDtoPurpose.fromJson(json['purpose'] as String),
  method: AdminPaymentDetailDtoMethod.fromJson(json['method'] as String),
  provider: AdminPaymentDetailDtoProvider.fromJson(json['provider'] as String),
  amountMinor: json['amountMinor'] as num,
  refundedMinor: json['refundedMinor'] as num,
  currency: json['currency'] as String,
  receiptNumber: json['receiptNumber'] as String?,
  failureCode: json['failureCode'] as String?,
  referenceType: json['referenceType'] as String?,
  referenceId: json['referenceId'] as String?,
  payer: AdminPayerDto.fromJson(json['payer'] as Map<String, dynamic>),
  providerReference: json['providerReference'] as String?,
  merchantReference: json['merchantReference'] as String?,
  msisdnLast4: json['msisdnLast4'] as String?,
  description: json['description'] as String?,
  failureReason: json['failureReason'] as String?,
  payeeId: json['payeeId'] as String?,
  platformFeeMinor: json['platformFeeMinor'] as num,
  queryAttempts: json['queryAttempts'] as num,
  lastQueriedAt: json['lastQueriedAt'] == null
      ? null
      : DateTime.parse(json['lastQueriedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  refundableMinor: json['refundableMinor'] as num,
  events: (json['events'] as List<dynamic>)
      .map((e) => AdminPaymentEventDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  refunds: (json['refunds'] as List<dynamic>)
      .map((e) => AdminRefundDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  ledger: (json['ledger'] as List<dynamic>)
      .map((e) => AdminLedgerEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AdminPaymentDetailDtoToJson(
  AdminPaymentDetailDto instance,
) => <String, dynamic>{
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
  'providerReference': instance.providerReference,
  'merchantReference': instance.merchantReference,
  'msisdnLast4': instance.msisdnLast4,
  'description': instance.description,
  'failureReason': instance.failureReason,
  'payeeId': instance.payeeId,
  'platformFeeMinor': instance.platformFeeMinor,
  'queryAttempts': instance.queryAttempts,
  'lastQueriedAt': instance.lastQueriedAt?.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'refundableMinor': instance.refundableMinor,
  'events': instance.events,
  'refunds': instance.refunds,
  'ledger': instance.ledger,
};

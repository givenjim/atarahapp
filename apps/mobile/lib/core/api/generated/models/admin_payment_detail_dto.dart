// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_ledger_entry_dto.dart';
import 'admin_payer_dto.dart';
import 'admin_payment_detail_dto_method.dart';
import 'admin_payment_detail_dto_provider.dart';
import 'admin_payment_detail_dto_purpose.dart';
import 'admin_payment_detail_dto_status.dart';
import 'admin_payment_event_dto.dart';
import 'admin_refund_dto.dart';

part 'admin_payment_detail_dto.g.dart';

@JsonSerializable()
class AdminPaymentDetailDto {
  const AdminPaymentDetailDto({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.purpose,
    required this.method,
    required this.provider,
    required this.amountMinor,
    required this.refundedMinor,
    required this.currency,
    required this.receiptNumber,
    required this.failureCode,
    required this.referenceType,
    required this.referenceId,
    required this.payer,
    required this.providerReference,
    required this.merchantReference,
    required this.msisdnLast4,
    required this.description,
    required this.failureReason,
    required this.payeeId,
    required this.platformFeeMinor,
    required this.queryAttempts,
    required this.lastQueriedAt,
    required this.expiresAt,
    required this.completedAt,
    required this.refundableMinor,
    required this.events,
    required this.refunds,
    required this.ledger,
  });
  
  factory AdminPaymentDetailDto.fromJson(Map<String, Object?> json) => _$AdminPaymentDetailDtoFromJson(json);
  
  final String id;
  final DateTime createdAt;
  final AdminPaymentDetailDtoStatus status;
  final AdminPaymentDetailDtoPurpose purpose;
  final AdminPaymentDetailDtoMethod method;
  final AdminPaymentDetailDtoProvider provider;
  final num amountMinor;
  final num refundedMinor;
  final String currency;
  final String? receiptNumber;
  final String? failureCode;
  final String? referenceType;
  final String? referenceId;
  final AdminPayerDto payer;
  final String? providerReference;
  final String? merchantReference;

  /// Last four digits of the paying number. The full number is never stored.
  final String? msisdnLast4;
  final String? description;
  final String? failureReason;
  final String? payeeId;
  final num platformFeeMinor;
  final num queryAttempts;
  final DateTime? lastQueriedAt;
  final DateTime? expiresAt;
  final DateTime? completedAt;

  /// Minor units that can still be refunded (excludes refunds in progress).
  final num refundableMinor;
  final List<AdminPaymentEventDto> events;
  final List<AdminRefundDto> refunds;
  final List<AdminLedgerEntryDto> ledger;

  Map<String, Object?> toJson() => _$AdminPaymentDetailDtoToJson(this);
}

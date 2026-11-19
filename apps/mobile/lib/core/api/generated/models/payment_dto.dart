// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payment_action_dto.dart';
import 'payment_dto_method.dart';
import 'payment_dto_purpose.dart';
import 'payment_dto_status.dart';

part 'payment_dto.g.dart';

@JsonSerializable()
class PaymentDto {
  const PaymentDto({
    required this.id,
    required this.status,
    required this.purpose,
    required this.method,
    required this.amountMinor,
    required this.currency,
    required this.description,
    required this.referenceType,
    required this.referenceId,
    required this.receiptNumber,
    required this.failureCode,
    required this.failureReason,
    required this.refundedMinor,
    required this.createdAt,
    required this.completedAt,
    required this.expiresAt,
    required this.timedOut,
    required this.pollAfterSeconds,
    this.action,
  });
  
  factory PaymentDto.fromJson(Map<String, Object?> json) => _$PaymentDtoFromJson(json);
  
  final String id;
  final PaymentDtoStatus status;
  final PaymentDtoPurpose purpose;
  final PaymentDtoMethod method;

  /// Minor units (KES cents).
  final num amountMinor;
  final String currency;
  final String? description;
  final String? referenceType;
  final String? referenceId;

  /// M-Pesa receipt once paid.
  final String? receiptNumber;

  /// Stable code such as CANCELLED_BY_USER or TIMEOUT.
  final String? failureCode;

  /// What to tell the member and what to do next.
  final String? failureReason;

  /// Minor units already refunded.
  final num refundedMinor;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;

  /// Still open after its time limit: the app offers "Try again" and the server keeps checking.
  final bool timedOut;

  /// Seconds the app should wait before asking again.
  final num pollAfterSeconds;

  /// Present on the response that starts a payment.
  final PaymentActionDto? action;

  Map<String, Object?> toJson() => _$PaymentDtoToJson(this);
}

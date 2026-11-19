// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_payer_dto.dart';
import 'admin_payment_dto_method.dart';
import 'admin_payment_dto_provider.dart';
import 'admin_payment_dto_purpose.dart';
import 'admin_payment_dto_status.dart';

part 'admin_payment_dto.g.dart';

@JsonSerializable()
class AdminPaymentDto {
  const AdminPaymentDto({
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
  });
  
  factory AdminPaymentDto.fromJson(Map<String, Object?> json) => _$AdminPaymentDtoFromJson(json);
  
  final String id;
  final DateTime createdAt;
  final AdminPaymentDtoStatus status;
  final AdminPaymentDtoPurpose purpose;
  final AdminPaymentDtoMethod method;
  final AdminPaymentDtoProvider provider;
  final num amountMinor;
  final num refundedMinor;
  final String currency;
  final String? receiptNumber;
  final String? failureCode;
  final String? referenceType;
  final String? referenceId;
  final AdminPayerDto payer;

  Map<String, Object?> toJson() => _$AdminPaymentDtoToJson(this);
}

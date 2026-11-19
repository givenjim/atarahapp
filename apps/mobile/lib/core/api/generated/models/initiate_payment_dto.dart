// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'initiate_payment_dto_method.dart';
import 'initiate_payment_dto_purpose.dart';

part 'initiate_payment_dto.g.dart';

@JsonSerializable()
class InitiatePaymentDto {
  const InitiatePaymentDto({
    required this.purpose,
    required this.method,
    this.referenceId,
    this.phone,
    this.sandboxAmountMinor,
  });
  
  factory InitiatePaymentDto.fromJson(Map<String, Object?> json) => _$InitiatePaymentDtoFromJson(json);
  
  final InitiatePaymentDtoPurpose purpose;

  /// What is being paid for (a booking, a membership order). The server decides the amount.
  final String? referenceId;
  final InitiatePaymentDtoMethod method;

  /// The Safaricom number that gets the M-Pesa prompt. Required for MPESA. Never stored in full.
  final String? phone;

  /// Only the OTHER (sandbox check) purpose reads this: minor units, KES 1 to 100. Ignored otherwise.
  final num? sandboxAmountMinor;

  Map<String, Object?> toJson() => _$InitiatePaymentDtoToJson(this);
}

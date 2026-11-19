// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'refund_payment_dto.g.dart';

@JsonSerializable()
class RefundPaymentDto {
  const RefundPaymentDto({
    required this.reason,
    this.amountMinor,
  });
  
  factory RefundPaymentDto.fromJson(Map<String, Object?> json) => _$RefundPaymentDtoFromJson(json);
  
  /// Minor units. Omit to refund everything still refundable.
  final num? amountMinor;

  /// Why (kept in the audit log).
  final String reason;

  Map<String, Object?> toJson() => _$RefundPaymentDtoToJson(this);
}

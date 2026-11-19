// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefundPaymentDto _$RefundPaymentDtoFromJson(Map<String, dynamic> json) =>
    RefundPaymentDto(
      reason: json['reason'] as String,
      amountMinor: json['amountMinor'] as num?,
    );

Map<String, dynamic> _$RefundPaymentDtoToJson(RefundPaymentDto instance) =>
    <String, dynamic>{
      'amountMinor': instance.amountMinor,
      'reason': instance.reason,
    };

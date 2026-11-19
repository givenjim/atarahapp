// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_payment_detail_dto.dart';

part 'post_api_v1_admin_payments_id_refunds_refund_id_complete_response.g.dart';

@JsonSerializable()
class PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponse {
  const PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponseFromJson(json);
  
  final AdminPaymentDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponseToJson(this);
}

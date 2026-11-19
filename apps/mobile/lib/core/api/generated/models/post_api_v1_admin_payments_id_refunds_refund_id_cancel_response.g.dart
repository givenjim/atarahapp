// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_payments_id_refunds_refund_id_cancel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminPaymentsIdRefundsRefundIdCancelResponse
_$PostApiV1AdminPaymentsIdRefundsRefundIdCancelResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminPaymentsIdRefundsRefundIdCancelResponse(
  data: AdminPaymentDetailDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminPaymentsIdRefundsRefundIdCancelResponseToJson(
  PostApiV1AdminPaymentsIdRefundsRefundIdCancelResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

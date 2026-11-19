// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_payments_id_refunds_refund_id_complete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponse
_$PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponse(
  data: AdminPaymentDetailDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponseToJson(
  PostApiV1AdminPaymentsIdRefundsRefundIdCompleteResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

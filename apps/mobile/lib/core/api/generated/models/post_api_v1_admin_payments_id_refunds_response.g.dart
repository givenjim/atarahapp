// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_payments_id_refunds_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminPaymentsIdRefundsResponse
_$PostApiV1AdminPaymentsIdRefundsResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminPaymentsIdRefundsResponse(
      data: AdminPaymentDetailDto.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminPaymentsIdRefundsResponseToJson(
  PostApiV1AdminPaymentsIdRefundsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

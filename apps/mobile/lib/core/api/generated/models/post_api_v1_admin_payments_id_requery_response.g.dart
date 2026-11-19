// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_payments_id_requery_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminPaymentsIdRequeryResponse
_$PostApiV1AdminPaymentsIdRequeryResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminPaymentsIdRequeryResponse(
      data: AdminPaymentDetailDto.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminPaymentsIdRequeryResponseToJson(
  PostApiV1AdminPaymentsIdRequeryResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

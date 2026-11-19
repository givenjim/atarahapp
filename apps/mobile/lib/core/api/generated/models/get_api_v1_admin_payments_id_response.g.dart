// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_payments_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminPaymentsIdResponse _$GetApiV1AdminPaymentsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminPaymentsIdResponse(
  data: AdminPaymentDetailDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminPaymentsIdResponseToJson(
  GetApiV1AdminPaymentsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_payments_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1PaymentsIdResponse _$GetApiV1PaymentsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1PaymentsIdResponse(
  data: PaymentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1PaymentsIdResponseToJson(
  GetApiV1PaymentsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

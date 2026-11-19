// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_payments_methods_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1PaymentsMethodsResponse _$GetApiV1PaymentsMethodsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1PaymentsMethodsResponse(
  data: PaymentMethodsDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1PaymentsMethodsResponseToJson(
  GetApiV1PaymentsMethodsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

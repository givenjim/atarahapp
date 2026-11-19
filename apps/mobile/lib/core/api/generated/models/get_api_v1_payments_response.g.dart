// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_payments_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1PaymentsResponse _$GetApiV1PaymentsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1PaymentsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => PaymentDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1PaymentsResponseToJson(
  GetApiV1PaymentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

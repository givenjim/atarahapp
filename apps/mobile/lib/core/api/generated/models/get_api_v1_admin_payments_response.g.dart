// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_payments_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminPaymentsResponse _$GetApiV1AdminPaymentsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminPaymentsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminPaymentDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminPaymentsResponseToJson(
  GetApiV1AdminPaymentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

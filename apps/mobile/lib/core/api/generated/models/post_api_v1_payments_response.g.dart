// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_payments_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1PaymentsResponse _$PostApiV1PaymentsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1PaymentsResponse(
  data: PaymentDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1PaymentsResponseToJson(
  PostApiV1PaymentsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

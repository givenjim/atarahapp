// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payment_methods_dto.dart';

part 'get_api_v1_payments_methods_response.g.dart';

@JsonSerializable()
class GetApiV1PaymentsMethodsResponse {
  const GetApiV1PaymentsMethodsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1PaymentsMethodsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1PaymentsMethodsResponseFromJson(json);
  
  final PaymentMethodsDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1PaymentsMethodsResponseToJson(this);
}

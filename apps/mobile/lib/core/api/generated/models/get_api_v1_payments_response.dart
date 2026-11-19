// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payment_dto.dart';

part 'get_api_v1_payments_response.g.dart';

@JsonSerializable()
class GetApiV1PaymentsResponse {
  const GetApiV1PaymentsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1PaymentsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1PaymentsResponseFromJson(json);
  
  final List<PaymentDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1PaymentsResponseToJson(this);
}

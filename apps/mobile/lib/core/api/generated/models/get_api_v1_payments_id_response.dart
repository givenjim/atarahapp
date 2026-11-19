// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payment_dto.dart';

part 'get_api_v1_payments_id_response.g.dart';

@JsonSerializable()
class GetApiV1PaymentsIdResponse {
  const GetApiV1PaymentsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1PaymentsIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1PaymentsIdResponseFromJson(json);
  
  final PaymentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1PaymentsIdResponseToJson(this);
}

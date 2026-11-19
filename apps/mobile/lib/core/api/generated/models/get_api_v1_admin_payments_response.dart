// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_payment_dto.dart';

part 'get_api_v1_admin_payments_response.g.dart';

@JsonSerializable()
class GetApiV1AdminPaymentsResponse {
  const GetApiV1AdminPaymentsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminPaymentsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminPaymentsResponseFromJson(json);
  
  final List<AdminPaymentDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminPaymentsResponseToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_payment_detail_dto.dart';

part 'get_api_v1_admin_payments_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminPaymentsIdResponse {
  const GetApiV1AdminPaymentsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminPaymentsIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminPaymentsIdResponseFromJson(json);
  
  final AdminPaymentDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminPaymentsIdResponseToJson(this);
}

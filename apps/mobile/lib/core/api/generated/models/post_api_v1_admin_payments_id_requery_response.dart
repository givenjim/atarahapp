// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_payment_detail_dto.dart';

part 'post_api_v1_admin_payments_id_requery_response.g.dart';

@JsonSerializable()
class PostApiV1AdminPaymentsIdRequeryResponse {
  const PostApiV1AdminPaymentsIdRequeryResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminPaymentsIdRequeryResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminPaymentsIdRequeryResponseFromJson(json);
  
  final AdminPaymentDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminPaymentsIdRequeryResponseToJson(this);
}

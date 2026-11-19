// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payment_dto.dart';

part 'post_api_v1_payments_response.g.dart';

@JsonSerializable()
class PostApiV1PaymentsResponse {
  const PostApiV1PaymentsResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1PaymentsResponse.fromJson(Map<String, Object?> json) => _$PostApiV1PaymentsResponseFromJson(json);
  
  final PaymentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1PaymentsResponseToJson(this);
}

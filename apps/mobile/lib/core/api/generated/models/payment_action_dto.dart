// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payment_action_dto_type.dart';

part 'payment_action_dto.g.dart';

@JsonSerializable()
class PaymentActionDto {
  const PaymentActionDto({
    required this.type,
    this.message,
    this.url,
  });
  
  factory PaymentActionDto.fromJson(Map<String, Object?> json) => _$PaymentActionDtoFromJson(json);
  
  final PaymentActionDtoType type;
  final String? message;
  final String? url;

  Map<String, Object?> toJson() => _$PaymentActionDtoToJson(this);
}

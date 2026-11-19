// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payment_method_option_dto_method.dart';

part 'payment_method_option_dto.g.dart';

@JsonSerializable()
class PaymentMethodOptionDto {
  const PaymentMethodOptionDto({
    required this.method,
    required this.label,
    required this.description,
  });
  
  factory PaymentMethodOptionDto.fromJson(Map<String, Object?> json) => _$PaymentMethodOptionDtoFromJson(json);
  
  final PaymentMethodOptionDtoMethod method;
  final String label;
  final String description;

  Map<String, Object?> toJson() => _$PaymentMethodOptionDtoToJson(this);
}

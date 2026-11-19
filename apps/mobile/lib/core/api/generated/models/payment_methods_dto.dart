// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payment_method_option_dto.dart';

part 'payment_methods_dto.g.dart';

@JsonSerializable()
class PaymentMethodsDto {
  const PaymentMethodsDto({
    required this.methods,
  });
  
  factory PaymentMethodsDto.fromJson(Map<String, Object?> json) => _$PaymentMethodsDtoFromJson(json);
  
  final List<PaymentMethodOptionDto> methods;

  Map<String, Object?> toJson() => _$PaymentMethodsDtoToJson(this);
}

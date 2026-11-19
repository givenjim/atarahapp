// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_option_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodOptionDto _$PaymentMethodOptionDtoFromJson(
  Map<String, dynamic> json,
) => PaymentMethodOptionDto(
  method: PaymentMethodOptionDtoMethod.fromJson(json['method'] as String),
  label: json['label'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$PaymentMethodOptionDtoToJson(
  PaymentMethodOptionDto instance,
) => <String, dynamic>{
  'method': instance.method,
  'label': instance.label,
  'description': instance.description,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_methods_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodsDto _$PaymentMethodsDtoFromJson(Map<String, dynamic> json) =>
    PaymentMethodsDto(
      methods: (json['methods'] as List<dynamic>)
          .map(
            (e) => PaymentMethodOptionDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$PaymentMethodsDtoToJson(PaymentMethodsDto instance) =>
    <String, dynamic>{'methods': instance.methods};

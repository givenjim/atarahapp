// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_action_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentActionDto _$PaymentActionDtoFromJson(Map<String, dynamic> json) =>
    PaymentActionDto(
      type: PaymentActionDtoType.fromJson(json['type'] as String),
      message: json['message'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PaymentActionDtoToJson(PaymentActionDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'url': instance.url,
    };

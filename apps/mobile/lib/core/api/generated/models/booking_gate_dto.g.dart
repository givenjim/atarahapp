// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_gate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingGateDto _$BookingGateDtoFromJson(Map<String, dynamic> json) =>
    BookingGateDto(
      allowed: json['allowed'] as bool,
      requiresPro: json['requiresPro'] as bool,
      isSelf: json['isSelf'] as bool,
    );

Map<String, dynamic> _$BookingGateDtoToJson(BookingGateDto instance) =>
    <String, dynamic>{
      'allowed': instance.allowed,
      'requiresPro': instance.requiresPro,
      'isSelf': instance.isSelf,
    };

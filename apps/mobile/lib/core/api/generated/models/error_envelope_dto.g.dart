// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorEnvelopeDto _$ErrorEnvelopeDtoFromJson(Map<String, dynamic> json) =>
    ErrorEnvelopeDto(
      error: Error.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ErrorEnvelopeDtoToJson(ErrorEnvelopeDto instance) =>
    <String, dynamic>{'error': instance.error};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_availability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandleAvailabilityDto _$HandleAvailabilityDtoFromJson(
  Map<String, dynamic> json,
) => HandleAvailabilityDto(
  handle: json['handle'] as String,
  available: json['available'] as bool,
  reason: json['reason'] == null
      ? null
      : HandleAvailabilityDtoReason.fromJson(json['reason'] as String),
  suggestions: (json['suggestions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$HandleAvailabilityDtoToJson(
  HandleAvailabilityDto instance,
) => <String, dynamic>{
  'handle': instance.handle,
  'available': instance.available,
  'reason': instance.reason,
  'suggestions': instance.suggestions,
};

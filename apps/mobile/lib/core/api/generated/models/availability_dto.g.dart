// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailabilityDto _$AvailabilityDtoFromJson(Map<String, dynamic> json) =>
    AvailabilityDto(
      timeZone: json['timeZone'] as String,
      weekly: (json['weekly'] as List<dynamic>)
          .map((e) => WeeklyRangeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      exceptions: (json['exceptions'] as List<dynamic>)
          .map((e) => ExceptionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextAvailableAt: json['nextAvailableAt'] == null
          ? null
          : DateTime.parse(json['nextAvailableAt'] as String),
    );

Map<String, dynamic> _$AvailabilityDtoToJson(AvailabilityDto instance) =>
    <String, dynamic>{
      'timeZone': instance.timeZone,
      'weekly': instance.weekly,
      'exceptions': instance.exceptions,
      'nextAvailableAt': instance.nextAvailableAt?.toIso8601String(),
    };

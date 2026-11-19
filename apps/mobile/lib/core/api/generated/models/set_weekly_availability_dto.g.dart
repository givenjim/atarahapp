// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_weekly_availability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetWeeklyAvailabilityDto _$SetWeeklyAvailabilityDtoFromJson(
  Map<String, dynamic> json,
) => SetWeeklyAvailabilityDto(
  weekly: (json['weekly'] as List<dynamic>)
      .map((e) => WeeklyRangeDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  timeZone: json['timeZone'] as String?,
);

Map<String, dynamic> _$SetWeeklyAvailabilityDtoToJson(
  SetWeeklyAvailabilityDto instance,
) => <String, dynamic>{
  'timeZone': instance.timeZone,
  'weekly': instance.weekly,
};

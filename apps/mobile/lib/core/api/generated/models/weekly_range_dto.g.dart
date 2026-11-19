// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_range_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyRangeDto _$WeeklyRangeDtoFromJson(Map<String, dynamic> json) =>
    WeeklyRangeDto(
      weekday: json['weekday'] as num,
      startMinute: json['startMinute'] as num,
      endMinute: json['endMinute'] as num,
    );

Map<String, dynamic> _$WeeklyRangeDtoToJson(WeeklyRangeDto instance) =>
    <String, dynamic>{
      'weekday': instance.weekday,
      'startMinute': instance.startMinute,
      'endMinute': instance.endMinute,
    };

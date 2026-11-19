// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'weekly_range_dto.dart';

part 'set_weekly_availability_dto.g.dart';

@JsonSerializable()
class SetWeeklyAvailabilityDto {
  const SetWeeklyAvailabilityDto({
    required this.weekly,
    this.timeZone,
  });
  
  factory SetWeeklyAvailabilityDto.fromJson(Map<String, Object?> json) => _$SetWeeklyAvailabilityDtoFromJson(json);
  
  /// IANA zone the ranges are in; defaults to the profile zone.
  final String? timeZone;

  /// Replaces the whole week.
  final List<WeeklyRangeDto> weekly;

  Map<String, Object?> toJson() => _$SetWeeklyAvailabilityDtoToJson(this);
}

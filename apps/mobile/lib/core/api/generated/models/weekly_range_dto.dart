// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'weekly_range_dto.g.dart';

@JsonSerializable()
class WeeklyRangeDto {
  const WeeklyRangeDto({
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
  });
  
  factory WeeklyRangeDto.fromJson(Map<String, Object?> json) => _$WeeklyRangeDtoFromJson(json);
  
  /// ISO weekday: 1 = Monday ... 7 = Sunday.
  final num weekday;

  /// Minutes after local midnight.
  final num startMinute;
  final num endMinute;

  Map<String, Object?> toJson() => _$WeeklyRangeDtoToJson(this);
}

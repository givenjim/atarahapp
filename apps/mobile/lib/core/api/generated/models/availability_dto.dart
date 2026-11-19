// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'exception_dto.dart';
import 'weekly_range_dto.dart';

part 'availability_dto.g.dart';

@JsonSerializable()
class AvailabilityDto {
  const AvailabilityDto({
    required this.timeZone,
    required this.weekly,
    required this.exceptions,
    this.nextAvailableAt,
  });
  
  factory AvailabilityDto.fromJson(Map<String, Object?> json) => _$AvailabilityDtoFromJson(json);
  
  final String timeZone;
  final List<WeeklyRangeDto> weekly;
  final List<ExceptionDto> exceptions;
  final DateTime? nextAvailableAt;

  Map<String, Object?> toJson() => _$AvailabilityDtoToJson(this);
}

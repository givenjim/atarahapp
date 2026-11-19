// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'slot_dto.dart';

part 'slots_dto.g.dart';

@JsonSerializable()
class SlotsDto {
  const SlotsDto({
    required this.mentorId,
    required this.sessionTypeId,
    required this.durationMinutes,
    required this.mentorTimeZone,
    required this.viewerTimeZone,
    required this.slots,
  });
  
  factory SlotsDto.fromJson(Map<String, Object?> json) => _$SlotsDtoFromJson(json);
  
  final String mentorId;
  final String sessionTypeId;
  final num durationMinutes;
  final String mentorTimeZone;
  final String viewerTimeZone;
  final List<SlotDto> slots;

  Map<String, Object?> toJson() => _$SlotsDtoToJson(this);
}

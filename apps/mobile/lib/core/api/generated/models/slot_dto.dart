// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'slot_dto.g.dart';

@JsonSerializable()
class SlotDto {
  const SlotDto({
    required this.startsAt,
    required this.endsAt,
    required this.localDate,
  });
  
  factory SlotDto.fromJson(Map<String, Object?> json) => _$SlotDtoFromJson(json);
  
  final DateTime startsAt;
  final DateTime endsAt;

  /// Calendar date `YYYY-MM-DD` in the member time zone.
  final String localDate;

  Map<String, Object?> toJson() => _$SlotDtoToJson(this);
}

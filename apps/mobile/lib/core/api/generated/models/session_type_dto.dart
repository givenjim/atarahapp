// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mentor_session_format.dart';

part 'session_type_dto.g.dart';

@JsonSerializable()
class SessionTypeDto {
  const SessionTypeDto({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.priceMinor,
    required this.currency,
    required this.format,
    required this.sessionCount,
    required this.active,
    required this.disabledByStaff,
    this.description,
  });
  
  factory SessionTypeDto.fromJson(Map<String, Object?> json) => _$SessionTypeDtoFromJson(json);
  
  final String id;
  final String name;
  final String? description;
  final num durationMinutes;

  /// Minor units.
  final num priceMinor;
  final String currency;
  final MentorSessionFormat format;
  final num sessionCount;
  final bool active;

  /// Staff switched it off; the mentor cannot turn it back on.
  final bool disabledByStaff;

  Map<String, Object?> toJson() => _$SessionTypeDtoToJson(this);
}

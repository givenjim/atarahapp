// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mentor_session_format.dart';

part 'admin_session_type_dto.g.dart';

@JsonSerializable()
class AdminSessionTypeDto {
  const AdminSessionTypeDto({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.priceMinor,
    required this.currency,
    required this.format,
    required this.sessionCount,
    required this.active,
    required this.disabledByStaff,
    required this.mentorId,
    required this.mentorName,
    this.description,
    this.staffNote,
  });
  
  factory AdminSessionTypeDto.fromJson(Map<String, Object?> json) => _$AdminSessionTypeDtoFromJson(json);
  
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
  final String mentorId;
  final String mentorName;
  final String? staffNote;

  Map<String, Object?> toJson() => _$AdminSessionTypeDtoToJson(this);
}

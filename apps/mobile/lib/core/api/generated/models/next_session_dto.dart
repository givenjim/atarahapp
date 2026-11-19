// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'next_session_dto.g.dart';

@JsonSerializable()
class NextSessionDto {
  const NextSessionDto({
    required this.bookingId,
    required this.mentorName,
    required this.sessionName,
    required this.startsAt,
  });
  
  factory NextSessionDto.fromJson(Map<String, Object?> json) => _$NextSessionDtoFromJson(json);
  
  final String bookingId;
  final String mentorName;
  final String sessionName;
  final DateTime startsAt;

  Map<String, Object?> toJson() => _$NextSessionDtoToJson(this);
}

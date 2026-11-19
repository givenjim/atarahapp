// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mentor_application_status.dart';
import 'mentor_card_dto.dart';
import 'next_session_dto.dart';

part 'mentorship_home_dto.g.dart';

@JsonSerializable()
class MentorshipHomeDto {
  const MentorshipHomeDto({
    required this.canBook,
    required this.isMentor,
    required this.topMentors,
    this.applicationStatus,
    this.nextSession,
  });
  
  factory MentorshipHomeDto.fromJson(Map<String, Object?> json) => _$MentorshipHomeDtoFromJson(json);
  
  /// The caller holds MENTORSHIP_BOOKING (Atarah Pro).
  final bool canBook;

  /// The caller is an approved, active mentor.
  final bool isMentor;
  final MentorApplicationStatus? applicationStatus;

  /// Filled by P2-M5; null until then.
  final NextSessionDto? nextSession;
  final List<MentorCardDto> topMentors;

  Map<String, Object?> toJson() => _$MentorshipHomeDtoToJson(this);
}

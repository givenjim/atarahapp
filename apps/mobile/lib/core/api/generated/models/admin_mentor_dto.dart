// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'applicant_ref_dto.dart';
import 'mentor_status.dart';

part 'admin_mentor_dto.g.dart';

@JsonSerializable()
class AdminMentorDto {
  const AdminMentorDto({
    required this.id,
    required this.mentor,
    required this.status,
    required this.headline,
    required this.featured,
    required this.sessionTypeCount,
    required this.ratingAverage,
    required this.ratingCount,
    required this.sessionsCount,
    this.statusReason,
    this.approvedAt,
  });
  
  factory AdminMentorDto.fromJson(Map<String, Object?> json) => _$AdminMentorDtoFromJson(json);
  
  final String id;
  final ApplicantRefDto mentor;
  final MentorStatus status;
  final String? statusReason;
  final String headline;
  final bool featured;
  final num sessionTypeCount;
  final num ratingAverage;
  final num ratingCount;
  final num sessionsCount;
  final DateTime? approvedAt;

  Map<String, Object?> toJson() => _$AdminMentorDtoToJson(this);
}

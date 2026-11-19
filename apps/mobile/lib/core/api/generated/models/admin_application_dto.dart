// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'applicant_ref_dto.dart';
import 'credential_out_dto.dart';
import 'mentor_application_status.dart';
import 'proposed_session_type_dto.dart';

part 'admin_application_dto.g.dart';

@JsonSerializable()
class AdminApplicationDto {
  const AdminApplicationDto({
    required this.id,
    required this.status,
    required this.headline,
    required this.yearsExperience,
    required this.statement,
    required this.expertiseTags,
    required this.disciplineIds,
    required this.credentials,
    required this.proposedSessionTypes,
    required this.evidenceLinks,
    required this.timeZone,
    required this.createdAt,
    required this.applicant,
    required this.passportSnapshot,
    this.reviewerNotes,
    this.reviewedAt,
    this.reviewedById,
  });
  
  factory AdminApplicationDto.fromJson(Map<String, Object?> json) => _$AdminApplicationDtoFromJson(json);
  
  final String id;
  final MentorApplicationStatus status;
  final String headline;
  final num yearsExperience;
  final String statement;
  final List<String> expertiseTags;
  final List<String> disciplineIds;
  final List<CredentialOutDto> credentials;
  final List<ProposedSessionTypeDto> proposedSessionTypes;
  final List<String> evidenceLinks;
  final String timeZone;

  /// Shown to the applicant when rejected.
  final String? reviewerNotes;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final ApplicantRefDto applicant;

  /// The Passport as it was when applying.
  final dynamic passportSnapshot;
  final String? reviewedById;

  Map<String, Object?> toJson() => _$AdminApplicationDtoToJson(this);
}

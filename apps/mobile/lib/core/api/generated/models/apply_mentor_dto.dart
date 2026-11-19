// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'credential_dto.dart';
import 'proposed_session_type_dto.dart';

part 'apply_mentor_dto.g.dart';

@JsonSerializable()
class ApplyMentorDto {
  const ApplyMentorDto({
    required this.headline,
    required this.yearsExperience,
    required this.expertiseTags,
    required this.disciplineIds,
    required this.credentials,
    required this.timeZone,
    required this.statement,
    required this.evidenceLinks,
    required this.proposedSessionTypes,
    required this.acceptTerms,
  });
  
  factory ApplyMentorDto.fromJson(Map<String, Object?> json) => _$ApplyMentorDtoFromJson(json);
  
  final String headline;
  final num yearsExperience;
  final List<String> expertiseTags;
  final List<String> disciplineIds;
  final List<CredentialDto> credentials;

  /// IANA time zone.
  final String timeZone;

  /// Why you want to mentor and who you can help.
  final String statement;

  /// https links that back up the application.
  final List<String> evidenceLinks;
  final List<ProposedSessionTypeDto> proposedSessionTypes;

  /// Must be true: the member accepted the Mentor Terms.
  final bool acceptTerms;

  Map<String, Object?> toJson() => _$ApplyMentorDtoToJson(this);
}

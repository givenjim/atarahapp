// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'availability_dto.dart';
import 'credential_out_dto.dart';
import 'discipline_ref_dto.dart';
import 'mentor_status.dart';
import 'session_type_dto.dart';

part 'my_mentor_dto.g.dart';

@JsonSerializable()
class MyMentorDto {
  const MyMentorDto({
    required this.id,
    required this.status,
    required this.headline,
    required this.bio,
    required this.yearsExperience,
    required this.expertiseTags,
    required this.disciplines,
    required this.credentials,
    required this.timeZone,
    required this.verified,
    required this.featured,
    required this.ratingAverage,
    required this.ratingCount,
    required this.sessionsCount,
    required this.sessionTypes,
    required this.availability,
    required this.listed,
    this.statusReason,
    this.videoCallLink,
  });
  
  factory MyMentorDto.fromJson(Map<String, Object?> json) => _$MyMentorDtoFromJson(json);
  
  final String id;
  final MentorStatus status;
  final String? statusReason;
  final String headline;
  final String bio;
  final num yearsExperience;
  final List<String> expertiseTags;
  final List<DisciplineRefDto> disciplines;
  final List<CredentialOutDto> credentials;
  final String timeZone;
  final String? videoCallLink;
  final bool verified;
  final bool featured;
  final num ratingAverage;
  final num ratingCount;
  final num sessionsCount;

  /// Including inactive ones.
  final List<SessionTypeDto> sessionTypes;
  final AvailabilityDto availability;

  /// Visible in the directory right now.
  final bool listed;

  Map<String, Object?> toJson() => _$MyMentorDtoToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'credential_dto.dart';

part 'update_mentor_profile_dto.g.dart';

@JsonSerializable()
class UpdateMentorProfileDto {
  const UpdateMentorProfileDto({
    this.headline,
    this.bio,
    this.yearsExperience,
    this.expertiseTags,
    this.disciplineIds,
    this.credentials,
    this.timeZone,
    this.videoCallLink,
  });
  
  factory UpdateMentorProfileDto.fromJson(Map<String, Object?> json) => _$UpdateMentorProfileDtoFromJson(json);
  
  final String? headline;
  final String? bio;
  final num? yearsExperience;
  final List<String>? expertiseTags;
  final List<String>? disciplineIds;
  final List<CredentialDto>? credentials;
  final String? timeZone;

  /// https meeting link; null clears it.
  final dynamic videoCallLink;

  Map<String, Object?> toJson() => _$UpdateMentorProfileDtoToJson(this);
}

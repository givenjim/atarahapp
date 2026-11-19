// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'credential_out_dto.dart';

part 'application_prefill_dto.g.dart';

@JsonSerializable()
class ApplicationPrefillDto {
  const ApplicationPrefillDto({
    required this.headline,
    required this.yearsExperience,
    required this.expertiseTags,
    required this.disciplineIds,
    required this.credentials,
    required this.statement,
    required this.timeZone,
    required this.profileReady,
  });
  
  factory ApplicationPrefillDto.fromJson(Map<String, Object?> json) => _$ApplicationPrefillDtoFromJson(json);
  
  final String headline;
  final num yearsExperience;
  final List<String> expertiseTags;
  final List<String> disciplineIds;
  final List<CredentialOutDto> credentials;
  final String statement;
  final String timeZone;

  /// The member profile is complete enough to apply.
  final bool profileReady;

  Map<String, Object?> toJson() => _$ApplicationPrefillDtoToJson(this);
}

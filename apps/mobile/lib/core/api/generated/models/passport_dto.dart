// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'completion_dto.dart';
import 'growth_dto.dart';
import 'location_dto.dart';
import 'section_visibility_dto.dart';

part 'passport_dto.g.dart';

@JsonSerializable()
class PassportDto {
  const PassportDto({
    required this.passportNumber,
    required this.issuedAt,
    required this.displayName,
    required this.handle,
    required this.avatarUrl,
    required this.discipline,
    required this.specialisation,
    required this.location,
    required this.memberSince,
    required this.trust,
    required this.growth,
    required this.completion,
    required this.sections,
    required this.shareUrl,
  });

  factory PassportDto.fromJson(Map<String, Object?> json) =>
      _$PassportDtoFromJson(json);

  final String passportNumber;
  final DateTime issuedAt;
  final String displayName;
  final String handle;
  final String? avatarUrl;
  final String? discipline;
  final String? specialisation;
  final LocationDto location;
  final DateTime memberSince;

  /// Trust pills. Empty until real verification exists.
  final List<String> trust;
  final GrowthDto growth;
  final CompletionDto completion;
  final List<SectionVisibilityDto> sections;
  final String shareUrl;

  Map<String, Object?> toJson() => _$PassportDtoToJson(this);
}

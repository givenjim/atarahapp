// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'completion_dto.dart';
import 'discipline_lite.dart';
import 'location_dto.dart';
import 'own_contact_dto.dart';
import 'own_counts_dto.dart';
import 'passport_summary_dto.dart';
import 'profile_link_dto.dart';
import 'section_visibility_dto.dart';
import 'taxonomy_item_dto.dart';

part 'own_profile_dto.g.dart';

@JsonSerializable()
class OwnProfileDto {
  const OwnProfileDto({
    required this.id,
    required this.handle,
    required this.displayName,
    required this.headline,
    required this.bio,
    required this.avatarUrl,
    required this.discipline,
    required this.specialisations,
    required this.skills,
    required this.location,
    required this.openToCommissions,
    required this.acceptConnections,
    required this.contact,
    required this.links,
    required this.sections,
    required this.completion,
    required this.passport,
    required this.onboardingCompleted,
    required this.memberSince,
    required this.counts,
    required this.shareUrl,
  });

  factory OwnProfileDto.fromJson(Map<String, Object?> json) =>
      _$OwnProfileDtoFromJson(json);

  final String id;
  final String? handle;
  final String displayName;
  final String? headline;
  final String? bio;
  final String? avatarUrl;
  final DisciplineLite? discipline;
  final List<TaxonomyItemDto> specialisations;
  final List<TaxonomyItemDto> skills;
  final LocationDto location;
  final bool openToCommissions;
  final bool acceptConnections;
  final OwnContactDto contact;
  final List<ProfileLinkDto> links;
  final List<SectionVisibilityDto> sections;
  final CompletionDto completion;
  final PassportSummaryDto? passport;
  final bool onboardingCompleted;
  final DateTime memberSince;
  final OwnCountsDto counts;

  /// https://atarah.app/{handle}
  final String? shareUrl;

  Map<String, Object?> toJson() => _$OwnProfileDtoToJson(this);
}

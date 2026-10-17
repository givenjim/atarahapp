// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'discipline_lite.dart';
import 'onboarding_profile_dto_location_visibility.dart';
import 'taxonomy_item_dto.dart';

part 'onboarding_profile_dto.g.dart';

@JsonSerializable()
class OnboardingProfileDto {
  const OnboardingProfileDto({
    required this.id,
    required this.displayName,
    required this.handle,
    required this.bio,
    required this.headline,
    required this.discipline,
    required this.specialisations,
    required this.skills,
    required this.interests,
    required this.developmentAreas,
    required this.countryId,
    required this.countryName,
    required this.countyId,
    required this.countyName,
    required this.town,
    required this.locationVisibility,
    required this.avatarUrl,
  });

  factory OnboardingProfileDto.fromJson(Map<String, Object?> json) =>
      _$OnboardingProfileDtoFromJson(json);

  final String id;
  final String displayName;
  final String? handle;
  final String? bio;
  final String? headline;
  final DisciplineLite? discipline;
  final List<TaxonomyItemDto> specialisations;
  final List<TaxonomyItemDto> skills;
  final List<TaxonomyItemDto> interests;
  final List<TaxonomyItemDto> developmentAreas;
  final String? countryId;
  final String? countryName;
  final String? countyId;
  final String? countyName;
  final String? town;
  final OnboardingProfileDtoLocationVisibility locationVisibility;

  /// Signed avatar URL (600 px), when a photo is set.
  final String? avatarUrl;

  Map<String, Object?> toJson() => _$OnboardingProfileDtoToJson(this);
}

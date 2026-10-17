// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'save_onboarding_step_dto_location_visibility.dart';
import 'save_onboarding_step_dto_step.dart';

part 'save_onboarding_step_dto.g.dart';

@JsonSerializable()
class SaveOnboardingStepDto {
  const SaveOnboardingStepDto({
    required this.step,
    this.skipped,
    this.disciplineId,
    this.specialisationIds,
    this.skillIds,
    this.interestIds,
    this.developmentAreaIds,
    this.countryId,
    this.countyId,
    this.town,
    this.locationVisibility,
    this.displayName,
    this.handle,
    this.bio,
  });

  factory SaveOnboardingStepDto.fromJson(Map<String, Object?> json) =>
      _$SaveOnboardingStepDtoFromJson(json);

  final SaveOnboardingStepDtoStep step;

  /// Skip this step: nothing is saved, the member moves on.
  final bool? skipped;

  /// DISCIPLINE. Changing it clears specialisations.
  final String? disciplineId;

  /// SPECIALISATION. Must belong to the chosen discipline.
  final List<String>? specialisationIds;

  /// SKILLS.
  final List<String>? skillIds;

  /// SKILLS.
  final List<String>? interestIds;

  /// SKILLS (areas to develop).
  final List<String>? developmentAreaIds;

  /// LOCATION.
  final String? countryId;

  /// LOCATION. Must belong to the country.
  final String? countyId;

  /// LOCATION. Optional town or neighbourhood.
  final String? town;

  /// LOCATION. Who can see the county.
  final SaveOnboardingStepDtoLocationVisibility? locationVisibility;

  /// BASICS.
  final String? displayName;

  /// BASICS. Lower-case letters, digits and underscores, 3 to 30 characters.
  final String? handle;

  /// BASICS. Short bio, up to 160 characters.
  final String? bio;

  Map<String, Object?> toJson() => _$SaveOnboardingStepDtoToJson(this);
}

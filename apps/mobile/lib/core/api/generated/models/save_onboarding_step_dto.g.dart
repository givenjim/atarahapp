// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_onboarding_step_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveOnboardingStepDto _$SaveOnboardingStepDtoFromJson(
  Map<String, dynamic> json,
) => SaveOnboardingStepDto(
  step: SaveOnboardingStepDtoStep.fromJson(json['step'] as String),
  skipped: json['skipped'] as bool?,
  disciplineId: json['disciplineId'] as String?,
  specialisationIds: (json['specialisationIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  skillIds: (json['skillIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  interestIds: (json['interestIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  developmentAreaIds: (json['developmentAreaIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  countryId: json['countryId'] as String?,
  countyId: json['countyId'] as String?,
  town: json['town'] as String?,
  locationVisibility: json['locationVisibility'] == null
      ? null
      : SaveOnboardingStepDtoLocationVisibility.fromJson(
          json['locationVisibility'] as String,
        ),
  displayName: json['displayName'] as String?,
  handle: json['handle'] as String?,
  bio: json['bio'] as String?,
);

Map<String, dynamic> _$SaveOnboardingStepDtoToJson(
  SaveOnboardingStepDto instance,
) => <String, dynamic>{
  'step': instance.step,
  'skipped': instance.skipped,
  'disciplineId': instance.disciplineId,
  'specialisationIds': instance.specialisationIds,
  'skillIds': instance.skillIds,
  'interestIds': instance.interestIds,
  'developmentAreaIds': instance.developmentAreaIds,
  'countryId': instance.countryId,
  'countyId': instance.countyId,
  'town': instance.town,
  'locationVisibility': instance.locationVisibility,
  'displayName': instance.displayName,
  'handle': instance.handle,
  'bio': instance.bio,
};

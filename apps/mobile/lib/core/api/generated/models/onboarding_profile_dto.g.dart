// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingProfileDto _$OnboardingProfileDtoFromJson(
  Map<String, dynamic> json,
) => OnboardingProfileDto(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  handle: json['handle'] as String?,
  bio: json['bio'] as String?,
  headline: json['headline'] as String?,
  discipline: json['discipline'] == null
      ? null
      : DisciplineLite.fromJson(json['discipline'] as Map<String, dynamic>),
  specialisations: (json['specialisations'] as List<dynamic>)
      .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  skills: (json['skills'] as List<dynamic>)
      .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  interests: (json['interests'] as List<dynamic>)
      .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  developmentAreas: (json['developmentAreas'] as List<dynamic>)
      .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  countryId: json['countryId'] as String?,
  countryName: json['countryName'] as String?,
  countyId: json['countyId'] as String?,
  countyName: json['countyName'] as String?,
  town: json['town'] as String?,
  locationVisibility: OnboardingProfileDtoLocationVisibility.fromJson(
    json['locationVisibility'] as String,
  ),
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$OnboardingProfileDtoToJson(
  OnboardingProfileDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'handle': instance.handle,
  'bio': instance.bio,
  'headline': instance.headline,
  'discipline': instance.discipline,
  'specialisations': instance.specialisations,
  'skills': instance.skills,
  'interests': instance.interests,
  'developmentAreas': instance.developmentAreas,
  'countryId': instance.countryId,
  'countryName': instance.countryName,
  'countyId': instance.countyId,
  'countyName': instance.countyName,
  'town': instance.town,
  'locationVisibility': instance.locationVisibility,
  'avatarUrl': instance.avatarUrl,
};

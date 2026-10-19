// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'own_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnProfileDto _$OwnProfileDtoFromJson(Map<String, dynamic> json) =>
    OwnProfileDto(
      id: json['id'] as String,
      handle: json['handle'] as String?,
      displayName: json['displayName'] as String,
      headline: json['headline'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      discipline: json['discipline'] == null
          ? null
          : DisciplineLite.fromJson(json['discipline'] as Map<String, dynamic>),
      specialisations: (json['specialisations'] as List<dynamic>)
          .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      openToCommissions: json['openToCommissions'] as bool,
      acceptConnections: json['acceptConnections'] as bool,
      contact: OwnContactDto.fromJson(json['contact'] as Map<String, dynamic>),
      links: (json['links'] as List<dynamic>)
          .map((e) => ProfileLinkDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => SectionVisibilityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      completion: CompletionDto.fromJson(
        json['completion'] as Map<String, dynamic>,
      ),
      passport: json['passport'] == null
          ? null
          : PassportSummaryDto.fromJson(
              json['passport'] as Map<String, dynamic>,
            ),
      onboardingCompleted: json['onboardingCompleted'] as bool,
      memberSince: DateTime.parse(json['memberSince'] as String),
      counts: OwnCountsDto.fromJson(json['counts'] as Map<String, dynamic>),
      shareUrl: json['shareUrl'] as String?,
    );

Map<String, dynamic> _$OwnProfileDtoToJson(OwnProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'headline': instance.headline,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'discipline': instance.discipline,
      'specialisations': instance.specialisations,
      'skills': instance.skills,
      'location': instance.location,
      'openToCommissions': instance.openToCommissions,
      'acceptConnections': instance.acceptConnections,
      'contact': instance.contact,
      'links': instance.links,
      'sections': instance.sections,
      'completion': instance.completion,
      'passport': instance.passport,
      'onboardingCompleted': instance.onboardingCompleted,
      'memberSince': instance.memberSince.toIso8601String(),
      'counts': instance.counts,
      'shareUrl': instance.shareUrl,
    };

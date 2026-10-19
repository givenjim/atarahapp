// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicProfileDto _$PublicProfileDtoFromJson(Map<String, dynamic> json) =>
    PublicProfileDto(
      handle: json['handle'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      headline: json['headline'] as String?,
      discipline: json['discipline'] == null
          ? null
          : DisciplineLite.fromJson(json['discipline'] as Map<String, dynamic>),
      specialisations: (json['specialisations'] as List<dynamic>)
          .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      openToCommissions: json['openToCommissions'] as bool,
      memberSince: DateTime.parse(json['memberSince'] as String),
      relation: PublicProfileDtoRelation.fromJson(json['relation'] as String),
      connection: json['connection'] == null
          ? null
          : ConnectionStateDto.fromJson(
              json['connection'] as Map<String, dynamic>,
            ),
      bio: json['bio'] as String?,
      location: json['location'] == null
          ? null
          : LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => ProfileLinkDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      contact: json['contact'] == null
          ? null
          : ContactDetailsDto.fromJson(json['contact'] as Map<String, dynamic>),
      visibleSections: (json['visibleSections'] as List<dynamic>)
          .map((e) => PublicProfileDtoVisibleSections.fromJson(e as String))
          .toList(),
      lockedSections: (json['lockedSections'] as List<dynamic>)
          .map((e) => PublicProfileDtoLockedSections.fromJson(e as String))
          .toList(),
      connectionCount: json['connectionCount'] as num?,
      shareUrl: json['shareUrl'] as String,
      portfolioCount: json['portfolioCount'] as num?,
      serviceCount: json['serviceCount'] as num?,
    );

Map<String, dynamic> _$PublicProfileDtoToJson(PublicProfileDto instance) =>
    <String, dynamic>{
      'handle': instance.handle,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'headline': instance.headline,
      'discipline': instance.discipline,
      'specialisations': instance.specialisations,
      'openToCommissions': instance.openToCommissions,
      'memberSince': instance.memberSince.toIso8601String(),
      'relation': instance.relation,
      'connection': instance.connection,
      'bio': instance.bio,
      'location': instance.location,
      'skills': instance.skills,
      'links': instance.links,
      'contact': instance.contact,
      'portfolioCount': instance.portfolioCount,
      'serviceCount': instance.serviceCount,
      'visibleSections': instance.visibleSections,
      'lockedSections': instance.lockedSections,
      'connectionCount': instance.connectionCount,
      'shareUrl': instance.shareUrl,
    };

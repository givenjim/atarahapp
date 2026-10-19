// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creative_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreativeCardDto _$CreativeCardDtoFromJson(Map<String, dynamic> json) =>
    CreativeCardDto(
      handle: json['handle'] as String,
      displayName: json['displayName'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      verified: json['verified'] as bool,
      openToCommissions: json['openToCommissions'] as bool,
      headline: json['headline'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      discipline: json['discipline'] == null
          ? null
          : DisciplineLite.fromJson(json['discipline'] as Map<String, dynamic>),
      location: json['location'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$CreativeCardDtoToJson(CreativeCardDto instance) =>
    <String, dynamic>{
      'handle': instance.handle,
      'displayName': instance.displayName,
      'headline': instance.headline,
      'avatarUrl': instance.avatarUrl,
      'discipline': instance.discipline,
      'tags': instance.tags,
      'location': instance.location,
      'verified': instance.verified,
      'openToCommissions': instance.openToCommissions,
      'reason': instance.reason,
    };

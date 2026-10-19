// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passport_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PassportDto _$PassportDtoFromJson(Map<String, dynamic> json) => PassportDto(
  passportNumber: json['passportNumber'] as String,
  issuedAt: DateTime.parse(json['issuedAt'] as String),
  displayName: json['displayName'] as String,
  handle: json['handle'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  discipline: json['discipline'] as String?,
  specialisation: json['specialisation'] as String?,
  location: LocationDto.fromJson(json['location'] as Map<String, dynamic>),
  memberSince: DateTime.parse(json['memberSince'] as String),
  trust: (json['trust'] as List<dynamic>).map((e) => e as String).toList(),
  growth: GrowthDto.fromJson(json['growth'] as Map<String, dynamic>),
  completion: CompletionDto.fromJson(
    json['completion'] as Map<String, dynamic>,
  ),
  sections: (json['sections'] as List<dynamic>)
      .map((e) => SectionVisibilityDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  shareUrl: json['shareUrl'] as String,
);

Map<String, dynamic> _$PassportDtoToJson(PassportDto instance) =>
    <String, dynamic>{
      'passportNumber': instance.passportNumber,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'displayName': instance.displayName,
      'handle': instance.handle,
      'avatarUrl': instance.avatarUrl,
      'discipline': instance.discipline,
      'specialisation': instance.specialisation,
      'location': instance.location,
      'memberSince': instance.memberSince.toIso8601String(),
      'trust': instance.trust,
      'growth': instance.growth,
      'completion': instance.completion,
      'sections': instance.sections,
      'shareUrl': instance.shareUrl,
    };

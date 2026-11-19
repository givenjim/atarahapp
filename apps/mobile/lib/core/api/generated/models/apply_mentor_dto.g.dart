// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_mentor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyMentorDto _$ApplyMentorDtoFromJson(Map<String, dynamic> json) =>
    ApplyMentorDto(
      headline: json['headline'] as String,
      yearsExperience: json['yearsExperience'] as num,
      expertiseTags: (json['expertiseTags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      disciplineIds: (json['disciplineIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => CredentialDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeZone: json['timeZone'] as String,
      statement: json['statement'] as String,
      evidenceLinks: (json['evidenceLinks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      proposedSessionTypes: (json['proposedSessionTypes'] as List<dynamic>)
          .map(
            (e) => ProposedSessionTypeDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      acceptTerms: json['acceptTerms'] as bool,
    );

Map<String, dynamic> _$ApplyMentorDtoToJson(ApplyMentorDto instance) =>
    <String, dynamic>{
      'headline': instance.headline,
      'yearsExperience': instance.yearsExperience,
      'expertiseTags': instance.expertiseTags,
      'disciplineIds': instance.disciplineIds,
      'credentials': instance.credentials,
      'timeZone': instance.timeZone,
      'statement': instance.statement,
      'evidenceLinks': instance.evidenceLinks,
      'proposedSessionTypes': instance.proposedSessionTypes,
      'acceptTerms': instance.acceptTerms,
    };

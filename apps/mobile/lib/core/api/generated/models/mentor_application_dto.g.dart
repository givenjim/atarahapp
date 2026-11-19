// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_application_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorApplicationDto _$MentorApplicationDtoFromJson(
  Map<String, dynamic> json,
) => MentorApplicationDto(
  id: json['id'] as String,
  status: MentorApplicationStatus.fromJson(json['status'] as String),
  headline: json['headline'] as String,
  yearsExperience: json['yearsExperience'] as num,
  statement: json['statement'] as String,
  expertiseTags: (json['expertiseTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  disciplineIds: (json['disciplineIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  credentials: (json['credentials'] as List<dynamic>)
      .map((e) => CredentialOutDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  proposedSessionTypes: (json['proposedSessionTypes'] as List<dynamic>)
      .map((e) => ProposedSessionTypeDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  evidenceLinks: (json['evidenceLinks'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  timeZone: json['timeZone'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  reviewerNotes: json['reviewerNotes'] as String?,
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
);

Map<String, dynamic> _$MentorApplicationDtoToJson(
  MentorApplicationDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'headline': instance.headline,
  'yearsExperience': instance.yearsExperience,
  'statement': instance.statement,
  'expertiseTags': instance.expertiseTags,
  'disciplineIds': instance.disciplineIds,
  'credentials': instance.credentials,
  'proposedSessionTypes': instance.proposedSessionTypes,
  'evidenceLinks': instance.evidenceLinks,
  'timeZone': instance.timeZone,
  'reviewerNotes': instance.reviewerNotes,
  'createdAt': instance.createdAt.toIso8601String(),
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
};

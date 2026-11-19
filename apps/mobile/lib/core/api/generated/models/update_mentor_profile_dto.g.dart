// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_mentor_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMentorProfileDto _$UpdateMentorProfileDtoFromJson(
  Map<String, dynamic> json,
) => UpdateMentorProfileDto(
  headline: json['headline'] as String?,
  bio: json['bio'] as String?,
  yearsExperience: json['yearsExperience'] as num?,
  expertiseTags: (json['expertiseTags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  disciplineIds: (json['disciplineIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  credentials: (json['credentials'] as List<dynamic>?)
      ?.map((e) => CredentialDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  timeZone: json['timeZone'] as String?,
  videoCallLink: json['videoCallLink'],
);

Map<String, dynamic> _$UpdateMentorProfileDtoToJson(
  UpdateMentorProfileDto instance,
) => <String, dynamic>{
  'headline': instance.headline,
  'bio': instance.bio,
  'yearsExperience': instance.yearsExperience,
  'expertiseTags': instance.expertiseTags,
  'disciplineIds': instance.disciplineIds,
  'credentials': instance.credentials,
  'timeZone': instance.timeZone,
  'videoCallLink': instance.videoCallLink,
};

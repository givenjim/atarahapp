// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_mentor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyMentorDto _$MyMentorDtoFromJson(Map<String, dynamic> json) => MyMentorDto(
  id: json['id'] as String,
  status: MentorStatus.fromJson(json['status'] as String),
  headline: json['headline'] as String,
  bio: json['bio'] as String,
  yearsExperience: json['yearsExperience'] as num,
  expertiseTags: (json['expertiseTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  disciplines: (json['disciplines'] as List<dynamic>)
      .map((e) => DisciplineRefDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  credentials: (json['credentials'] as List<dynamic>)
      .map((e) => CredentialOutDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  timeZone: json['timeZone'] as String,
  verified: json['verified'] as bool,
  featured: json['featured'] as bool,
  ratingAverage: json['ratingAverage'] as num,
  ratingCount: json['ratingCount'] as num,
  sessionsCount: json['sessionsCount'] as num,
  sessionTypes: (json['sessionTypes'] as List<dynamic>)
      .map((e) => SessionTypeDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  availability: AvailabilityDto.fromJson(
    json['availability'] as Map<String, dynamic>,
  ),
  listed: json['listed'] as bool,
  statusReason: json['statusReason'] as String?,
  videoCallLink: json['videoCallLink'] as String?,
);

Map<String, dynamic> _$MyMentorDtoToJson(MyMentorDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'statusReason': instance.statusReason,
      'headline': instance.headline,
      'bio': instance.bio,
      'yearsExperience': instance.yearsExperience,
      'expertiseTags': instance.expertiseTags,
      'disciplines': instance.disciplines,
      'credentials': instance.credentials,
      'timeZone': instance.timeZone,
      'videoCallLink': instance.videoCallLink,
      'verified': instance.verified,
      'featured': instance.featured,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'sessionsCount': instance.sessionsCount,
      'sessionTypes': instance.sessionTypes,
      'availability': instance.availability,
      'listed': instance.listed,
    };

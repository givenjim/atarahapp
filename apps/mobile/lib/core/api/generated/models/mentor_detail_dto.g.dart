// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorDetailDto _$MentorDetailDtoFromJson(Map<String, dynamic> json) =>
    MentorDetailDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      headline: json['headline'] as String,
      expertiseTags: (json['expertiseTags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      verified: json['verified'] as bool,
      featured: json['featured'] as bool,
      ratingAverage: json['ratingAverage'] as num,
      ratingCount: json['ratingCount'] as num,
      sessionsCount: json['sessionsCount'] as num,
      currency: json['currency'] as String,
      timeZone: json['timeZone'] as String,
      videoCall: json['videoCall'] as bool,
      bio: json['bio'] as String,
      yearsExperience: json['yearsExperience'] as num,
      disciplines: (json['disciplines'] as List<dynamic>)
          .map((e) => DisciplineRefDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => CredentialOutDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sessionTypes: (json['sessionTypes'] as List<dynamic>)
          .map((e) => SessionTypeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      booking: BookingGateDto.fromJson(json['booking'] as Map<String, dynamic>),
      handle: json['handle'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      fromPriceMinor: json['fromPriceMinor'] as num?,
      nextAvailableAt: json['nextAvailableAt'] == null
          ? null
          : DateTime.parse(json['nextAvailableAt'] as String),
    );

Map<String, dynamic> _$MentorDetailDtoToJson(MentorDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'headline': instance.headline,
      'expertiseTags': instance.expertiseTags,
      'verified': instance.verified,
      'featured': instance.featured,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'sessionsCount': instance.sessionsCount,
      'fromPriceMinor': instance.fromPriceMinor,
      'currency': instance.currency,
      'nextAvailableAt': instance.nextAvailableAt?.toIso8601String(),
      'timeZone': instance.timeZone,
      'videoCall': instance.videoCall,
      'bio': instance.bio,
      'yearsExperience': instance.yearsExperience,
      'disciplines': instance.disciplines,
      'credentials': instance.credentials,
      'sessionTypes': instance.sessionTypes,
      'booking': instance.booking,
    };

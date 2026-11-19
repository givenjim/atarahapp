// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_mentor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminMentorDto _$AdminMentorDtoFromJson(Map<String, dynamic> json) =>
    AdminMentorDto(
      id: json['id'] as String,
      mentor: ApplicantRefDto.fromJson(json['mentor'] as Map<String, dynamic>),
      status: MentorStatus.fromJson(json['status'] as String),
      headline: json['headline'] as String,
      featured: json['featured'] as bool,
      sessionTypeCount: json['sessionTypeCount'] as num,
      ratingAverage: json['ratingAverage'] as num,
      ratingCount: json['ratingCount'] as num,
      sessionsCount: json['sessionsCount'] as num,
      statusReason: json['statusReason'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
    );

Map<String, dynamic> _$AdminMentorDtoToJson(AdminMentorDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mentor': instance.mentor,
      'status': instance.status,
      'statusReason': instance.statusReason,
      'headline': instance.headline,
      'featured': instance.featured,
      'sessionTypeCount': instance.sessionTypeCount,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'sessionsCount': instance.sessionsCount,
      'approvedAt': instance.approvedAt?.toIso8601String(),
    };

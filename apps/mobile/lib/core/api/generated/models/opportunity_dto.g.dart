// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpportunityDto _$OpportunityDtoFromJson(Map<String, dynamic> json) =>
    OpportunityDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      type: OpportunityType.fromJson(json['type'] as String),
      title: json['title'] as String,
      summary: json['summary'] as String,
      trust: OpportunityTrust.fromJson(json['trust'] as String),
      provider: OpportunityProviderLiteDto.fromJson(
        json['provider'] as Map<String, dynamic>,
      ),
      workMode: WorkMode.fromJson(json['workMode'] as String),
      featured: json['featured'] as bool,
      saved: json['saved'] as bool,
      closed: json['closed'] as bool,
      about: json['about'] as String,
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      benefits: (json['benefits'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      applicationMethod: ApplicationMethod.fromJson(
        json['applicationMethod'] as String,
      ),
      profileGap: ProfileGapDto.fromJson(
        json['profileGap'] as Map<String, dynamic>,
      ),
      shareUrl: json['shareUrl'] as String,
      valueLabel: json['valueLabel'] as String?,
      deadlineAt: json['deadlineAt'] == null
          ? null
          : DateTime.parse(json['deadlineAt'] as String),
      daysLeft: json['daysLeft'] as num?,
      urgency: json['urgency'] == null
          ? null
          : OpportunityDtoUrgency.fromJson(json['urgency'] as String),
      locationLabel: json['locationLabel'] as String?,
      tracking: json['tracking'] == null
          ? null
          : TrackingStateDto.fromJson(json['tracking'] as Map<String, dynamic>),
      applicationUrl: json['applicationUrl'] as String?,
      applicationEmail: json['applicationEmail'] as String?,
      applicationDomain: json['applicationDomain'] as String?,
      disciplines: (json['disciplines'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OpportunityDtoToJson(OpportunityDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'type': instance.type,
      'title': instance.title,
      'summary': instance.summary,
      'trust': instance.trust,
      'provider': instance.provider,
      'valueLabel': instance.valueLabel,
      'deadlineAt': instance.deadlineAt?.toIso8601String(),
      'daysLeft': instance.daysLeft,
      'urgency': instance.urgency,
      'workMode': instance.workMode,
      'locationLabel': instance.locationLabel,
      'featured': instance.featured,
      'saved': instance.saved,
      'tracking': instance.tracking,
      'closed': instance.closed,
      'about': instance.about,
      'requirements': instance.requirements,
      'benefits': instance.benefits,
      'applicationMethod': instance.applicationMethod,
      'applicationUrl': instance.applicationUrl,
      'applicationEmail': instance.applicationEmail,
      'applicationDomain': instance.applicationDomain,
      'disciplines': instance.disciplines,
      'profileGap': instance.profileGap,
      'shareUrl': instance.shareUrl,
    };
